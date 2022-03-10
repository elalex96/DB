USE Adinco
GO
DROP PROCEDURE IF EXISTS EN_sp_GuardaRelacionDocumentoS3Bitacora
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 10/Marzo/2022
-- Description:	Se guarda la relación del documento subido al S3 con el de la bitácora, marca como procesado el dicho registro y manda notificación al usuario
-- =============================================
GO
CREATE PROC EN_sp_GuardaRelacionDocumentoS3Bitacora
@IdBitacora int,
@IdDocumento int,
@IdUsuario int,
@IdContrato int,
@Server varchar(300),
@NombreDocumento varchar(1000)
AS
BEGIN
DECLARE
@pIdNotificacion int,
@Mensaje varchar(1000),
@NombreUsuario varchar(1000) = (SELECT TOP 1
								US.Nombre
								FROM AP_Usuario AS US
								WHERE UsuarioID = @IdUsuario), 
@para varchar(1000) = (SELECT TOP 1
								US.Usuario
								FROM AP_Usuario AS US
								WHERE UsuarioID = @IdUsuario),
@HTML varchar(max) = 
 '<p></p>
<table class="full" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td height="25">&nbsp;</td>
</tr>
</tbody>
</table>
<table class="full" border="0" width="100%" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td align="center">
<table class="devicewidth" border="0" width="600" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td>
<table class="full" style="border-radius: 6px 6px 0 0;" width="100%" cellspacing="0" cellpadding="0" align="center" bgcolor="#5e5f5e">
<tbody>
<tr>
<td height="3">&nbsp;</td>
</tr>
<tr>
<td>
<table class="inner" style="border-collapse: collapse;" border="0" align="left">
<tbody>
<tr>
<td class="inner" valign="middle" height="45"><a><img class="logo" style="padding-left: 2em;" src="https://is4-ssl.mzstatic.com/image/thumb/Purple113/v4/41/ee/c9/41eec948-00b3-5528-87b1-d989929f6ec4/source/60x60bb.jpg" width="75" height="75" /></a></td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td height="3">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<!--CUERPO DEL MENSAJE DE CORREO-->
<table class="devicewidth" border="0" width="600" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td>
<table class="full" style="background-repeat: repeat-x; background-position: left top; height: 259px; width: 100%;" border="0" width="100%" cellpadding="0" align="center" bgcolor="#FFFFFF">
<tbody>
<tr style="height: 25px;">
<td style="height: 25px;" height="25">&nbsp;</td>
</tr>
<tr style="height: 36px;">
<td class="smallfont" style="color: black; height: 36px;" align="center">Estimado(a) ##NombreUsuario##</td>
</tr>
<tr style="height: 18px;">
<td class="smallfont" style="color: black; height: 18px;" align="center">&nbsp;</td>
</tr>
<tr style="height: 18px;">
<td class="smallfont" style="color: red; height: 18px;" align="center">&nbsp;</td>
</tr>
<tr style="height: 108px;">
<td class="smallfont" style="color: black; height: 108px;" align="center">
<br />##Mensaje##
<br />
</td>
<tr>
<td class="smallfont" style="font: 600 12px "Open Sans", Arial, Helvetica, sans-serif; color: #5e5f5e;" align="center">Ingrese a Adinco para descargar su documento. 
<br /><br /><a style="font-size: 12px; font-family: Helvetica, Arial, sans-serif; color: #ffffff; line-height: 10px; text-decoration: none; -webkit-border-radius: 5px; -moz-border-radius: 5px; border-radius: 5px; padding: 10px 10px; display: inline-block; letter-spacing: 1px; text-align: center; font-weight: bold; text-transform: uppercase; width: 8em; background: #2DB360;" 
href="##URL_TAREA##/2/Entregables/ReporteSasisopa.aspx" target="_blank" name="btnDetalle"> Ver listado de Documentos</a> <br /><br /></td>
</tr>
</tr>
<tr style="height: 18px;">
<td style="height: 18px;" height="16">&nbsp;</td>
</tr>
<tr style="height: 18px;">
<td class="smallfont" style="color: #5e5f5e; height: 18px;" align="center">&nbsp;</td>
</tr>
<tr style="height: 18px;">
<td style="height: 18px;" height="10">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table class="full" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td align="center">
<table class="devicewidth" border="0" width="600" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td>
<table class="full" style="border-radius: 0 0 6px 6px;" width="100%" cellspacing="0" cellpadding="0" align="center" bgcolor="#5e5f5e">
<tbody>
<tr>
<td height="18">&nbsp;</td>
</tr>
<tr>
<td>
<table class="inner" style="border-collapse: collapse; text-align: center;" border="0" width="230" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td width="20">&nbsp;</td>
<td>
<table border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td style="color: #ffffff;">|</td>
<td style="font: 10px Helvetica,Arial, sans-serif; color: #ffffff;" align="center">&copy; ##YEAR_ACTUAL##, Todos los derechos reservados</td>
<td style="color: #ffffff;">|</td>
</tr>
<tr>
<td height="15">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
<td width="20">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>';
	-- SE ACTUALIZA EL PROCESADO
	UPDATE EN_Documentos_BitacoraReporteSASISOPA
	SET Procesado = 1
	WHERE Id = @IdBitacora
	-- SE AGREGA LA BITÁCORA 
	INSERT INTO EN_DocumentosSASISOPA_Relacion(
	IdBitacoraReporte,	IdDocumento,	NombreDocumento) 
	VALUES (
	@IdBitacora,		@IdDocumento,	@NombreDocumento)
	-- SE INSERTA LA NOTIFICACIÓN 
	SET @Mensaje = (CONCAT('Su documento  "',@NombreDocumento,'" está disponible para descargarlo, puede consultarlo ahora.'));
	SET @HTML = (replace(@HTML,'##NombreUsuario##',@NombreUsuario))
	SET @HTML = (replace(@HTML,'##Mensaje##', @Mensaje))
	SET @HTML = (replace(@HTML,'##YEAR_ACTUAL##',CAST(YEAR(getdate()) as varchar(10))))
	SET @HTML = (replace(@HTML,'##URL_TAREA##', @Server))
	
	select @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
			from Adinco..S_Notificacion

	insert into Adinco..S_Notificacion(
				IdNotificacion,			Para,			Asunto,							Mensaje,		
				FechaProgramadaEnvio,	Enviada,		FechaEnvio,		CreadoPor,
				CreadoEl,				ModificadoPor,	ModificadoEl,	De,				EN_MsjEnviado)
				VALUES (
				@pIdNotificacion ,		@para,			'Descargade Reporte SASISOPA',	isnull(@HTML,''),
				getdate(),				0,				null,			1,
				getdate(),				null,			null,			'notificaciones@adinco.mx',null)
END