' ********************************************************************
' **  HLS Stream App with HTTP Basic Authentication
' **  Derived from Sample PlayVideo App from formus.roku.com user 'luma' @ https://forums.roku.com/viewtopic.php?t=83458
' **  Copyright (c) 2009 Roku Inc. All Rights Reserved.
' ********************************************************************

Sub Main(args As Dynamic)
    displayVideo()
End Sub

Function displayVideo()
    debug = 0

    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)
    video.AddHeader("Authorization", getAuthorizationHeaderValue())
    video.SetContent(getVideoClip())
    video.show()

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then
                print "Closing video screen"
                exit while
            else if debug and msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else if debug
                print "Unknown event: "; msg.GetType(); " - "; msg.GetMessage()
            endif
        end if
    end while
End Function

Function getAuthorizationHeaderValue()
    pass = getPassword()

    userpass = box(config().username)
    userpass.AppendString(":", 1)
    userpass.AppendString(pass, pass.Len())

    ba = CreateObject("roByteArray")
    ba.FromAsciiString(userpass)
    base64_userpass = ba.ToBase64String()

    authorization_value = box("Basic ")
    authorization_value.AppendString(base64_userpass, base64_userpass.Len())

    return authorization_value
End Function

Function getPassword()
     screen = CreateObject("roKeyboardScreen")
     port = CreateObject("roMessagePort")
     screen.SetMessagePort(port)
     screen.SetTitle("Password")
     screen.SetText("")
     screen.SetDisplayText("Enter Password")
     screen.SetMaxLength(8)
     screen.SetSecureText(1)
     screen.AddButton(1, "Done")
     screen.Show()

     while true
         msg = wait(0, screen.GetMessagePort())
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isButtonPressed() and msg.GetIndex() = 1 or msg.isScreenClosed()
                 password = screen.GetText()
                 return password
             end if
         end if
     end while
End Function

Function getVideoClip()
    'bitrates  = [0]          ' 0 = no dots, adaptive bitrate
    'bitrates  = [348]    ' <500 Kbps = 1 dot
    'bitrates  = [664]    ' <800 Kbps = 2 dots
    'bitrates  = [996]    ' <1.1Mbps  = 3 dots
    'bitrates  = [2048]    ' >=1.1Mbps = 4 dots
    bitrates  = [0]

    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = [ config().url ]
    videoclip.StreamQualities = ["HD"]
    videoclip.StreamFormat = "hls"
    videoclip.Title = "Stream"

    return videoclip
End Function
