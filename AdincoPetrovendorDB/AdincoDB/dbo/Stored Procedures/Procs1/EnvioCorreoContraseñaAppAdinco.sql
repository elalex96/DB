-- Stored Procedure

-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01-11/17
-- Description:envia correo de cambio de contraseña 
-- =============================================
CREATE PROCEDURE [dbo].[EnvioCorreoContraseñaAppAdinco]
	-- Add the parameters for the stored procedure here
	@idUser int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
Declare @usuario varchar(50)		
SELECT Top 1 @usuario= Usuario
	from Ap_Usuario  WHERE UsuarioID=@idUser;

Declare @nombre varchar(50)		
SELECT Top 1 @nombre= Nombre from Ap_Usuario  WHERE UsuarioID=@idUser;

DECLARE @LastChangeDate  varchar(50)
 
SELECT @LastChangeDate =  CONVERT(VARCHAR(10), GETDATE(), 103)

DECLARE @MyTime varchar(50)
 SELECT @Mytime= CONVERT(VARCHAR, getdate(), 108) 
-------------------------------
insert into S_Notificacion
(idnotificacion,
Para,
Asunto,
Mensaje,
FechaProgramadaEnvio,
Enviada,
FechaEnvio,
CreadoPor,
CreadoEl,
ModificadoPor,
ModificadoEl,
De) values ((Select Max(idNotificacion)+1 from S_Notificacion),@usuario,'Actualización de contraseña','<title>Modificacion de Contraseña</title>
    <style type="text/css">
        div, p, a, li, td {
            -webkit-text-size-adjust: none;
        }
        .ReadMsgBody {
            width: 100%;
            background-color: #d1d1d1;
        }
        .ExternalClass {
            width: 100%;
            background-color: #d1d1d1;
            line-height: 100%;
        }
        body {
            width: 100%;
            height: 100%;
            background-color: #d1d1d1;
            margin: 0;
            padding: 0;
            -webkit-font-smoothing: antialiased;
            -webkit-text-size-adjust: 100%;
        }
        html {
            width: 100%;
        }
     
        table[class=full] {
            padding: 0 !important;
            border: none !important;
        }
        table td img[class=imgresponsive] {
            width: 100% !important;
            height: auto !important;
            display: block !important;
        }
        @media only screen and (max-width: 800px) {
            body {
                width: auto !important;
            }
            table[class=full] {
                width: 100% !important;
            }
            table[class=devicewidth] {
                width: 100% !important;
                padding-left: 20px !important;
                padding-right: 20px !important;
            }
            table td img.responsiveimg {
                width: 100% !important;
                height: auto !important;
                display: block !important;
            }
        }
        @media only screen and (max-width: 640px) {
            table[class=devicewidth] {
                width: 100% !important;
            }
            table[class=inner] {
                width: 100% !important;
                text-align: center !important;
                clear: both;
            }
            table td a[class=top-button] {
                width: 160px !important;
                font-size: 14px !important;
                line-height: 37px !important;
            }
            table td[class=readmore-button] {
                text-align: center !important;
            }
                table td[class=readmore-button] a {
                    float: none !important;
                    display: inline-block !important;
                }
            .hide {
                display: none !important;
            }
            table td[class=smallfont] {
                border: none !important;
                font-size: 26px !important;
            }
            table td[class=sidespace] {
                width: 10px !important;
            }
        }
        @media only screen and (max-width: 520px) {
        }
        @media only screen and (max-width: 480px) {
            table {
                border-collapse: collapse;
            }
                table td[class=template-img] img {
                    width: 100% !important;
                    display: block !important;}}@media only screen and (max-width: 320px) {}</style></head>
<body><table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full"><tr><td height="25">&nbsp;</td></tr></table><table width="100%" border="0" cellspacing="0" cellpadding="0" class="full"><tr><td align="center"><table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth"><tr><td><table width="100%" bgcolor="#5e5f5e" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius: 6px 6px 0 0;"><tr><td height="3"></td></tr><tr><td><table border="0" align="left" class="inner" style="border-collapse: collapse;"><tr><td height="45" class="inner" valign="middle"></td></tr></table></td></tr><tr><td height="3"></td></tr></table></td></tr></table></td></tr></table>
<table width="100%" cellspacing="0" cellpadding="0" align="center" class="full"><tr><td align="center"><table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth"><tr><td><table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="background-repeat: repeat-x; background-position: left top;"><tr><td height="25">&nbsp;</td></tr><tr><td align="center" style="font: 600 18px "Open Sans", Arial, Helvetica, sans-serif; color: black;" class="smallfont"><singleline>Hola  '+@nombre+'<br></singleline></td></tr> <tr><td align="center" style="font: 200 14px "Open Sans", Arial, Helvetica, sans-serif; color:black;padding-left: 3em;padding-right: 3em" class="smallfont"> <singleline> <br>Tu contraseña ha sido actualizada correctamente</singleline></td></tr><tr><td align="center" style="font: 200 14px "Open Sans", Arial, Helvetica, sans-serif; color:black;padding-left: 3em;padding-right: 3em" class="smallfont">
<singleline> <br> Cambio realizado el '+@LastChangeDate+' a las '+@MyTime+' hrs
</singleline></td></tr><td align="center" style="font: 200 14px "Open Sans", Arial, Helvetica, sans-serif; color:black;" class="smallfont"><br><singleline>Atentamente <br>Equipo Adinco. </singleline> </td></tr> <tr><td height="10">&nbsp;</td></tr> </table> </td></tr> </table></td> </tr></table><table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full"><tr><td align="center"><table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth"> <tr> <td> <table width="100%" bgcolor="#5e5f5e" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius: 0 0 6px 6px;"> <tr> <td height="18"></td> </tr> <tr><td><table class="inner" align="center" width="230" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; text-align: center; ">
<tr><td width="20">&nbsp;</td><td> <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center"><tr> <td style="color: #FFFFFF;">|</td><td align="center" style="font: 10px Helvetica,  Arial, sans-serif; color: #FFFFFF;"><singleline>&copy; 2017, Todos los derechos reservados</singleline>
</td> <td style="color: #FFFFFF;">| </td></tr> <tr><td height="15">&nbsp;</td></tr></table></td><td width="20">&nbsp;</td></tr></table></td></tr> </table></td> </tr></table> </td></tr> </table></body></html>
', getDate(),0,getDate(),1,getDate(),null,getDate(),'procura@adinco.mx');
END
