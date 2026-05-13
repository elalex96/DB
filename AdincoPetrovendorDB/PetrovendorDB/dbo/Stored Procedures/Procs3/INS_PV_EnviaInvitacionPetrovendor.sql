USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'INS_PV_EnviaInvitacionPetrovendor'
)
 DROP PROCEDURE INS_PV_EnviaInvitacionPetrovendor;
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author: Daniel AC
---- Create date: 21-11-2024
---- Description: Generar correo de invitación a proveedores o clientes a petrovendor
---- =============================================
---- =============================================
---- Author: Daniel AC
---- Create date: 28-04-2025
---- Description: Se retorna la lista de correos 
---- =============================================
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[INS_PV_EnviaInvitacionPetrovendor]
@RFCEmisor varchar(100),
@CorreoInvitado varchar(100),
@IdUsuario int = null,
@IdContrato int = null,
@Origen varchar(100)

AS
BEGIN
	
DECLARE @HTMLCORREOSINV NVARCHAR(MAX),
		@IDCORREO INT,
		@ASUNTOCORREO varchar(1000),
		@EmpresaEmisora varchar(max),
		@CorreoNotificaciones NVARCHAR(MAX),
		@Dominio NVARCHAR(MAX);
		

		SELECT @HTMLCORREOSINV = HTML,
		@IDCORREO = IdCorreo,
		@ASUNTOCORREO = Asunto
		FROM TA_CORREO (NOLOCK)
		WHERE ASUNTO = 'Invitación para unirse a Petrovendor'

		SELECT @EmpresaEmisora = RazonSocial 
		FROM S_Proveedor (NOLOCK)
		WHERE RFC = @RFCEmisor 
		AND Activo = 1

		SELECT  TOP 1  @CorreoNotificaciones = CuentaRegistro
		FROM TA_Correo AS C (NOLOCK)
			INNER JOIN TA_CorreoServidor AS S (NOLOCK)
				ON C.IdServidor = S.IdServidor
		WHERE IdCorreo = @IDCORREO --> CTE NUMERO CORREO (TA_Correo)

		SELECT  @Dominio = Url
		FROM TA_Dominios  (NOLOCK)
		WHERE IdDominio = 1 --> CTE PETROVENDOR

        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##NombreEmpresa##', ISNULL(@EmpresaEmisora,'')));
        SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV, '##ANIO_ACTUAL##', YEAR(GETDATE())));
        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##DOMINIO##', ISNULL(@Dominio,'')));


	SELECT 
	Destinatario = @CorreoInvitado,
    Asunto = @ASUNTOCORREO,
    Mensaje = @HTMLCORREOSINV

END