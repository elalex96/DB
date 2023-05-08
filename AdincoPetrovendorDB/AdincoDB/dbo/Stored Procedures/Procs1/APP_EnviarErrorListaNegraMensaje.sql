CREATE PROCEDURE APP_EnviarErrorListaNegraMensaje
    @IdUsuario int,
	@Mensaje VARCHAR(5000),
	@Asunto VARCHAR(300)
as
BEGIN
    DECLARE @IdNotificacion INT,@fecha DATETIME;

    SELECT @IdNotificacion = MAX(IdNotificacion) + 1
    FROM S_Notificacion;

    SELECT @fecha = GETDATE();

    SELECT @fecha = DATEADD(MI, 1, @fecha);

    INSERT INTO S_Notificacion
    SELECT @IdNotificacion,
           'soporte@adinco.mx',
           @Asunto,
           '<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link href=''http://fonts.googleapis.com/css?family=Open+Sans:400,300,700,600'' rel=''stylesheet'' 
	type=''text/css''><title>Tareas</title><style type="text/css">div, p, a, li, td {-webkit-text-size-adjust: none;}.ReadMsgBody {width: 100%;background-color: #d1d1d1;}.ExternalClass {width: 100%;background-color: #d1d1d1;line-height: 100%;}
	body {width: 100%;height: 100%;background-color: #d1d1d1;margin: 0;padding: 0;-webkit-font-smoothing: antialiased;-webkit-text-size-adjust: 100%;}html {width: 100%;}img {-ms-interpolation-mode: bicubic;}table[class=full] {padding: 0 !important;border: no
ne !important;}table td img[class=imgresponsive] {width: 100% !important;height: auto !important;display: block !important;}@media only screen and (max-width: 800px) {body {width: auto !important;}table[class=full] {width: 100% !important;}table[class=dev
icewidth] {width: 100% !important;padding-left: 20px !important;padding-right: 20px !important;}table td img.responsiveimg {width: 100% !important;height: auto !important;display: block !important;}}@media only screen and (max-width: 640px) {table[class=d
evicewidth] {width: 100% !important;}table[class=inner] {width: 100% !important;text-align: center !important;clear: both;}table td a[class=top-button] {width: 160px !important;font-size: 14px !important;line-height: 37px !important;}table td[class=readmo
re-button] {text-align: center !important;}table td[class=readmore-button] a {float: none !important;display: inline-block !important;}.hide {display: none !important;}table td[class=smallfont] {border: none !important;font-size: 26px !important;}table td
[class=sidespace] {width: 10px !important;}}@media only screen and (max-width: 520px) {}@media only screen and (max-width: 480px) {table {border-collapse: collapse;}table td[class=template-img] img {width: 100% !important;display: block !important;}}@medi
a only screen and (max-width: 320px) {}a.enlaces {font-family: "Arial";font-size: 9pt;text-decoration: none;}a.enlaces:hover {text-decoration: underline;font-weight: bold;}</style></head><body><table width="100%" border="0" cellspacing="0" cellpadding="0"
 align="center" class="full"><tr><td height="25">&nbsp;</td></tr></table><table width="100%" border="0" cellspacing="0" cellpadding="0" class="full"><tr><td align="center"><table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class=
"devicewidth"><tr><td><table width="100%" bgcolor="#5e5f5e" cell2023spacing="0" cellpadding="0" align="center" class="full" style="border-radius: 6px 6px 0 0;"><tr><td height="3"></td></tr><tr><td><table border="0" align="left" class="inner" style="border-col
lapse: collapse;"><tr><td height="45" class="inner" valign="middle"><a><img style="padding-left:2em" 
	class="logo" src="http://qa.procura.adinco.mx/assets/00/img/SMPS_Logo.png" width="75" height="75" label="Logo"></a></td></tr></table></td></tr><tr><td height="3"></td></tr></table></td></tr></table></td></tr></table><!--CUERPO DEL MENSAJE DE CORREO--><ta
ble width="100%" cellspacing="0" cellpadding="0" align="center" class="full"><tr><td align="center"><table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth"><tr><td><table width="100%" bgcolor="#FFFFFF" border="0" c
ellspacing="0" cellpadding="0" align="center" class="full" style="background-repeat: repeat-x; background-position: left top;"><tr><td height="25">&nbsp;</td></tr><tr><td align="center" style="font: 600 18px ''Open Sans'', Arial, Helvetica, sans-serif; co
lor: black;" class="smallfont">
	<singleline>Estimado(a) Usuario<br></singleline>
	<singleline>Dear User<br></singleline>
	</td></tr><tr><td align="center" style="font: 200 14px ''Open Sans'', Arial, Helvetica, sans-serif; color:black;" class="smallfont"><br><singleline></singleline></td></tr><tr><td align="center" style="font: 600 14px ''Open Sans'', Arial, Helvetica, sans-
serif; color:red;" class="smallfont"><singleline></singleline></td></tr><tr><td align="center" style="font: 200 14px ''Open Sans'', Arial, Helvetica, sans-serif; color:black;" class="smallfont">
	<singleline>
		<br>'+@Mensaje+'
	</singleline></td></tr><tr><td height="16">&nbsp;</td></tr><tr><td align="center" style="font: 600 12px ''Open Sans'', Arial, Helvetica, sans-serif; color: #5e5f5e;" class="smallfont">
	</td></tr><tr><td height="10">&nbsp;</td></tr></table></td></tr></table></td></tr>
	</table><table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full"><tr><td align="center">
	<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth"><tr><td>
	<table width="100%" bgcolor="#5e5f5e" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius: 0 0 6px 6px;"><tr><td height="18"></td></tr><tr><td>
	<table class="inner" align="center" width="230" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; text-align: center; "><tr><td width="20">&nbsp;</td><td>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center"><tr><td style="color: #FFFFFF;">|</td><td align="center" style="font: 10px Helvetica,Arial, sans-serif; color: #FFFFFF;">
	<singleline>&copy; 2023, Todos los derechos reservados</singleline></td><td style="color: #FFFFFF;">|</td></tr><tr><td height="15">&nbsp;</td></tr></table></td><td width="20">&nbsp;</td></tr>
	</table></td></tr></table></td></tr></table></td></tr></table></body></html>',
           @fecha,
           0,
           null,
           @IdUsuario,
           getdate(),
           null,
           null,
           'procura@adinco.mx',
           null;

END