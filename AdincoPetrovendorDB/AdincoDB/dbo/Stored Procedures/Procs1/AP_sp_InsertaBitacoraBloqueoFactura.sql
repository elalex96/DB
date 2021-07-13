
--Modifier: Luis David De La Cruz
-- Modifier date: 24-06-2021
-- Description: Inserta en bitacora de carga facturas
-----------------------------------------------------
--Modifier: Luis David De La Cruz
-- Modifier date: 13-07-2021
-- Description: Se inserta el correo cuando se bloquea a un proveedor
DROP PROCEDURE IF EXISTS AP_sp_InsertaBitacoraBloqueoFactura
GO
CREATE PROCEDURE AP_sp_InsertaBitacoraBloqueoFactura
@IdProveedor int,
@IdProveedorBloqueado Int,
@IdUsuario int,
@Motivo varchar(300),
@Bloqueado bit
as
begin
DECLARE @descripcionStr varchar(100),
@mensaje varchar(max)='
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:400,300,700,600" rel="stylesheet" type="text/css">
		<title>kreative</title>
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
			img {
				-ms-interpolation-mode: bicubic;
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
						display: block !important;
					}
			}
			@media only screen and (max-width: 320px) {
			}
		</style>
	</head>
	<body>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
			<tr>
				<td height="50">&nbsp;</td>
			</tr>
	</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
			<tr>
				<td align="center">
					<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
						<tr>
							<td>
								<table width="100%" bgcolor="#ffffff" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius:7px 7px 0 0;">
									<tr>
										<td style="padding-left:1em; padding-bottom:.5em; padding-top:.5em">
											<table border="0" cellspacing="0" cellpadding="0" align="left" class="inner" style="border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt;">
												<tr>
													<td height="75" class="inner" valign="middle"><a href="#"><img editable class="logo" src="http://nebula.wsimg.com/2b23f4ec51a1fa0e225516e95a09cb07?AccessKeyId=77F4177CB326D3D4EA57&disposition=0&alloworigin=1" width="80" height="80" label="Logo"></a></td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="full">
			<tr>
				<td align="center">
					<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
						<tr>
							<td>
								<table width="100%" bgcolor="#585858" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="background-image:url(images/white-bg.gif); background-repeat:repeat-x; background-position:left top;">
							</td>
						</tr>
						<tr>
							<td height="20">&nbsp;</td>
						</tr>
						<tr>
							<td align="center" style="font:300 27px "Open Sans", Arial, Helvetica, sans-serif; color:#16c4a9;" class="smallfont">
								<singleline>
									Estimado Proveedor
								</singleline>
							</td>
						</tr>
						<tr>
							<td>
								<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
									<tr>
										<td width="30%" height="2"></td>
										<td width="10%" style="border-bottom:1.5px solid #ffffff"></td>
										<td width="30%" height="2"></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td height="16">&nbsp;</td>
						</tr>
						<tr>
							<td align="center" style="font:700 27px "Open Sans", Arial, Helvetica, sans-serif; color:#FFFFFF;" class="smallfont">
								<singleline>
									Debido a la falta de complementos de pago o algún otro inconveniente administrativo, tu usuario ha sido temporalmente inhabilitado para cargar facturas remitidas a Wintershall DEA Mexico, en el portal de Petrovendor.
									<br>
									<br>
									Para mayor información, por favor contacta al correo a invoice.mexico@wintershalldea.com.
								</singleline>
							</td>
						</tr>
						<tr>
							<td height="10">&nbsp;</td>
						</tr>
						<tr>
							<td height="10">&nbsp;</td>
							</tr>
							<tr>
							<td height="20">&nbsp;</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
			<tr>
				<td align="center">
					<table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
						<tr>
							<td>
								<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius:0 0 7px 7px;">
									<tr>
										<td>
											<table class="inner" align="left" width="230" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; text-align:center;">
												<tr>
													<td width="20">&nbsp;</td>
													<td style="padding-bottom:1em;padding-top:1em">
														<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
															<tr>
																<td align="center" style="font:11px Helvetica,  Arial, sans-serif; color:#000000;"><singleline>&copy; 2021, Todos los derechos reservados</singleline> </td>
															</tr>
														</table>
													</td>
													<td width="20">&nbsp;</td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</body>
</html>',
@pIdNotificacion int,
@rows int,
@Counter INT,
@idtipousuario int = (SELECT TOP 1 IdTipoUsuario 
						FROM S_TipoUsuario where 
						NombreTipoUsuario = 'Administrador' 
						AND Activo = 1);
	if @Bloqueado = 1
	begin
		SET @descripcionStr = ('Bloqueo');
		-- CUANDO SEA BLOQUEO ENTRARÁ A MANDAR LA NOTIFICACIÓN AL USUARIO ADMINISTRADOR BLOQEUADO
		drop table if exists #UsuariosProveedor
		CREATE TABLE #UsuariosProveedor
		(
			id int primary key not null identity(1,1),
			IdUsuario int
		)
		INSERT INTO #UsuariosProveedor(IdUsuario) 
		SELECT IdUsuario FROM S_UsuarioProveedor WHERE IdProveedor = @IdProveedorBloqueado
		SET @Counter=1
		SET @rows = (SELECT 
					count(*) 
					FROM S_Usuario u
					JOIN S_TipoUsuario ut	
					ON u.IdTipoUsuario = ut.IdTipoUsuario
					join #UsuariosProveedor tu
					on u.IdUsuario = tu.IdUsuario
					AND u.IdTipoUsuario = @idtipousuario)
		WHILE (@Counter <= @rows)
		BEGIN
			set @pIdNotificacion = 0
			set @pIdNotificacion = (select isnull(max(IdNotificacion),0) + 1 from Adinco..S_Notificacion) -- Obtiene el id de la ultima notificación
			insert into Adinco..S_Notificacion(
				IdNotificacion,
				Para,							Asunto,						Mensaje,
				FechaProgramadaEnvio,			Enviada,					FechaEnvio,			CreadoPor,
				CreadoEl,						ModificadoPor,				ModificadoEl,		De,
				EN_MsjEnviado
			)
			SELECT 
				@pIdNotificacion, 
				Correo,							'Deshabilitacion de carga de factura Petrovendor' ,	@mensaje ,
				dateadd(HOUR,-3,getdate()) ,	0 ,							null ,				1,
				GETDATE() CreadoEl,				null,						null,				'notificaciones@adinco.mx',		
				null
			FROM S_Usuario u
			JOIN S_TipoUsuario ut	
			ON u.IdTipoUsuario = ut.IdTipoUsuario
			join #UsuariosProveedor tup
			on u.IdUsuario = tup.IdUsuario
			AND u.IdTipoUsuario = @idtipousuario
			where tup.id  = @Counter --Se hace el where con el id

			SET @Counter  = @Counter  + 1
		END --End while

	end
	else
	begin
		SET @descripcionStr = ('Desbloqueo')
	end
	INSERT INTO AP_BitacoraBloqueoFactura(
	Motivo,			Descripcion,		Bloqueado,		IdProveedorBloqueado,
	IdProveedor,	CreadoEl,			CreadoPor) 
	VALUES (
	@Motivo,		@descripcionStr,	@Bloqueado,		@IdProveedorBloqueado,
	@IdProveedor,	GETDATE(),			@IdUsuario)
end