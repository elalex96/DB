USE Petrovendor
GO
DROP PROC IF EXISTS INS_PV_EnviaInvitacionPetrovendor
GO
CREATE PROC INS_PV_EnviaInvitacionPetrovendor
@RFCEmisor varchar(100),
@CorreoInvitado varchar(100),
@IdUsuario int = null,
@IdContrato int = null
AS
BEGIN
	
DECLARE @HTMLCORREOSINV NVARCHAR(MAX) = (SELECT HTML FROM TA_CORREO WHERE ASUNTO = 'Invitación para unirse a Petrovendor'),
		@IDCORREO INT = (SELECT IdCorreo FROM TA_CORREO WHERE ASUNTO = 'Invitación para unirse a Petrovendor'),
		@ASUNTOCORREO varchar(1000) = (SELECT Asunto FROM TA_CORREO WHERE ASUNTO = 'Invitación para unirse a Petrovendor'),
		@EmpresaEmisora varchar(max) = (Select RazonSocial from S_Proveedor where RFC = @RFCEmisor and Activo = 1),
		@IdNotificacion BIGINT,
		@CorreoNotificaciones NVARCHAR(MAX)
		;


		SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = @IDCORREO) --> CTE NUMERO CORREO (TA_Correo)

        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##NombreEmpresa##', @EmpresaEmisora));
        SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV, '##ANIO_ACTUAL##', YEAR(GETDATE())));
        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##DOMINIO##', 'https://petrovendor.com.mx/'));


        SET @IdNotificacion = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);

		--Envio de notificacion
        INSERT INTO Adinco.dbo.S_Notificacion
        (
            IdNotificacion,
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
            De
        )
        VALUES
        (@IdNotificacion, @CorreoInvitado, @ASUNTOCORREO,
         @HTMLCORREOSINV, DATEADD(MINUTE, 1, GETDATE()), 0, NULL, 3, GETDATE(), NULL, NULL,
         ISNULL(@CorreoNotificaciones,''));

		--Guardado de bitácora
		---
		INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)
        VALUES
        (   @IdNotificacion,                                                          -- IdEnvioAdinco - int
            @IDCORREO,                                                                -- CORREO DE INVITACIÓN
            'Invitación para unirse a Petrovendor.',
            1, GETDATE());

END
