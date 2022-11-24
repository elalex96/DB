CREATE PROCEDURE Carso_sp_EnviaCorreosComparativasPendientes
@ComparativaHtml varchar(max)
AS
BEGIN
DECLARE
@pIdNotificacion int,
@counterComparativas int = 0,
@counterWhile int = 1, 
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
<td class="smallfont" style="color: black; height: 108px;" align="center"><br />A continuación, se muestra el resultado del procesamiento de las comparativas pendientes<br /><br />##Detalle##</td>
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
SET @HTML = (replace(@HTML,'##Detalle##',@ComparativaHtml));
SET @HTML = (replace(@HTML,'##YEAR_ACTUAL##',CAST(YEAR(getdate()) as varchar(10))))
DROP TABLE IF EXISTS #CorreosPendientes
CREATE TABLE #CorreosPendientes(
Id int primary key not null identity (1,1),
CuerpoCorreo VARCHAR(MAX),
IdUsuario INT
)
insert into #CorreosPendientes(
	CuerpoCorreo,									IdUsuario
)
SELECT 
	@HTML,	CD.Idusuario FROM  
Carso_Comparativa_Destinatarios CD
where CD.Activo = 1

SET @counterComparativas = (SELECT COUNT(1) FROM #CorreosPendientes);

WHILE @counterWhile <= @counterComparativas
	BEGIN
		SELECT @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
		FROM Adinco..S_Notificacion

		INSERT INTO Adinco..S_Notificacion(
		IdNotificacion,		Para,			Asunto,			
		Mensaje,			FechaProgramadaEnvio,
		Enviada,			FechaEnvio,		CreadoPor,		CreadoEl,		ModificadoPor,
		ModificadoEl,		De,				EN_MsjEnviado)
		select 
		@pIdNotificacion ,	U.Correo,		'Resultado de Procesamiento de Comparativas',
		REPLACE(@HTML,'##NombreUsuario##',u.Nombre),	getdate(),
		0,					null,			1,getdate(),null,
		null,				'notificaciones@adinco.mx',null
		FROM #CorreosPendientes AS CP
		JOIN S_Usuario U
		ON CP.IdUsuario = U.IdUsuario
		WHERE CP.Id = @counterWhile
		SET @counterWhile = (@counterWhile + 1);
	END
END
