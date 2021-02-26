-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:solo cambia el estatus para la instancia 
-- =============================================
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 24/02/2021
-- Description: Modificaciones para usuario equinor
-- =============================================
ALTER PROCEDURE [dbo].[sp_En_SubeHistoricoAprueba] 
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idContratoEntregable INT,
    @ComentarioUsuarioElaborador VARCHAR(500),
    @URLRepositorio VARCHAR(1500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ActividadSiguienteID INT,
            @ActividadIDActual INT,
            @IdLineaTiempo INT,
            @idVersion INT,
            @ContieneURLRepositorio BIT,
            @idUsuarioRevisor INT,
            @idUsuarioAprobador INT;
	DECLARE @Contratos TABLE (IdContrato INT);
	DECLARE @IsEquinor BIT = 0;

	--CONTRATOS PARA VALIDACION DE EQUINOR
	INSERT INTO @Contratos (IdContrato) VALUES (3);--MEXICO PRUEBAS DEV
	INSERT INTO @Contratos
	SELECT 
		CON.IdContrato
	FROM dbo.CO_Contrato AS CON
	LEFT JOIN dbo.CO_Contratista AS CI ON CON.IdContratista = CON.IdContratista
	WHERE CI.RFC = 'SEM150122M86'--EQUINOR

	IF EXISTS (SELECT * FROM @Contratos WHERE IdContrato = @IdContrato)
	BEGIN

		IF EXISTS (SELECT
					PU.UsuarioID
					FROM dbo.AP_PerfilUsuario AS PU
						JOIN dbo.AP_Perfil AS P 
							ON PU.PerfilID = P.IdPerfil
						JOIN dbo.AP_Rol AS R
							ON P.IdRol = R.IdRol
					WHERE PU.UsuarioID = @IdUsuario
						AND P.IdContrato = @IdContrato
						AND R.Rol IN ('Administrador de Entregables  (Contrato)',
										'Administración general de entregables')
					)
		BEGIN

			SET @IsEquinor = 1;

		END

	END

    SELECT @ActividadIDActual = ActividadID
    FROM dbo.EN_InstanciasEntregable
    WHERE idInstanciaEntregable = @idInstanciaEntregable;

    SELECT TOP 1
           @idUsuarioRevisor = CASE
                                   WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                       exa.idUsuario
                                   ELSE
                                       a.idUsuario
                               END
    FROM dbo.EN_Actividad a
    LEFT JOIN dbo.EN_ExcepcionesActividad exa ON a.ActividadID = exa.ActividadIDExcepcion
                                                 AND exa.IdInstanciasEntregables = @idInstanciaEntregable
    WHERE a.IdContratoEntregable = @idContratoEntregable
          AND a.EstadoID = 10001;


    SELECT @ActividadSiguienteID = ActividadID,
           @idUsuarioAprobador = CASE
                                     WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                         exa.idUsuario
                                     ELSE
                                         a.idUsuario
                                 END
    FROM dbo.EN_Actividad a
    LEFT JOIN dbo.EN_ExcepcionesActividad exa ON a.ActividadID = exa.ActividadIDExcepcion
                                                 AND exa.IdInstanciasEntregables = @idInstanciaEntregable
    WHERE a.IdContratoEntregable = @idContratoEntregable
          AND a.EstadoID = 10003;

    UPDATE EN_InstanciasEntregable
    SET ActividadID = @ActividadSiguienteID,
        FechaElaboro = GETDATE()
    WHERE idInstanciaEntregable = @idInstanciaEntregable;

    SELECT @IdLineaTiempo = ISNULL(MAX(IdLineaTiempo), 0)
    FROM dbo.EN_HistorialAprobacionesLineaTiempo;
    SET @idVersion = (@IdLineaTiempo + 1);

    IF @ComentarioUsuarioElaborador = ''
    BEGIN
        SET @ComentarioUsuarioElaborador = 'Usuario elaborador a enviado a revisión el entregable';
    END;

    IF (@URLRepositorio = '' OR @URLRepositorio IS NULL)
    BEGIN
        SET @URLRepositorio = 'No se ingreso URL de repositorio';
        SET @ContieneURLRepositorio = 0;
    END;
    ELSE
    BEGIN
        SET @ContieneURLRepositorio = 1;
    END;

	---ACTUALIZACION DE LOS DATOS DE LOS ACUSES
	IF @IsEquinor = 1
	BEGIN

		UPDATE EN_HistorialAprobacionesLineaTiempo
		SET IdLineaTiempo = @idVersion
		WHERE idInstanciaEntregable = @idInstanciaEntregable

		UPDATE dbo.EN_DocumentoVersion
		SET N_version = @idVersion
		WHERE idInstanciaEntregable = @idInstanciaEntregable

	END

	/* 10,003*/--Registro de elaboración
	IF @IsEquinor = 1
	BEGIN
		
			IF NOT EXISTS (SELECT IdLineaTiempo 
					FROM dbo.EN_HistorialAprobacionesLineaTiempo AS HA 
					WHERE HA.IdLineaTiempo = @idVersion
						AND HA.idInstanciaEntregable = @idInstanciaEntregable
						AND HA.idContrato = @idContrato
						AND HA.idTipoOperacion = 2)
			BEGIN
				
				EXEC EN_GuardaHistorialLineaTiempo @idVersion,
                                       @idInstanciaEntregable,
                                       @idUsuario,
                                       @idContrato,
                                       @ComentarioUsuarioElaborador,
                                       0,
                                       2, --Elaborador
                                       0,
                                       @URLRepositorio,
                                       @ContieneURLRepositorio;

			END

	END
	ELSE
	BEGIN
		
		EXEC EN_GuardaHistorialLineaTiempo @idVersion,
                                       @idInstanciaEntregable,
                                       @idUsuario,
                                       @idContrato,
                                       @ComentarioUsuarioElaborador,
                                       0,
                                       2, --Elaborador
                                       0,
                                       @URLRepositorio,
                                       @ContieneURLRepositorio;

	END

    

	IF @IsEquinor = 1
	BEGIN
		
		IF NOT EXISTS (SELECT IdLineaTiempo 
					FROM dbo.EN_HistorialAprobacionesLineaTiempo AS HA 
					WHERE HA.IdLineaTiempo = @idVersion
						AND HA.idInstanciaEntregable = @idInstanciaEntregable
						AND HA.idContrato = @idContrato
						AND HA.idTipoOperacion = 3)
		BEGIN
			
			EXEC EN_GuardaHistorialLineaTiempo @idVersion, --Revisión
                                       @idInstanciaEntregable,
                                       @idUsuarioRevisor,
                                       @idContrato,
                                       '',
                                       0,
                                       3, --Revisor
                                       0,
										'En este paso no se ingresa URL (Aprobado Directamente)',
                                       0;

		END


	END
	ELSE
	BEGIN
		
		EXEC EN_GuardaHistorialLineaTiempo @idVersion, --Revisión
                                       @idInstanciaEntregable,
                                       @idUsuarioRevisor,
                                       @idContrato,
                                       '',
                                       0,
                                       3, --Revisor
                                       0,
									  'En este paso no se ingresa URL (Aprobado Directamente)',
                                       0;

	END

    
	/*Cuando sea caso 10,002 omitir este paso*/
    EXEC EN_GuardaHistorialLineaTiempo @idVersion, --Aprobación
                                       @idInstanciaEntregable,
                                       @idUsuarioAprobador,
                                       @idContrato,
                                       '',
                                       0,
                                       4,--Aprobador
                                       0,
                                       'En este paso no se ingresa URL (Aprobado Directamente)',
                                       0;
--------------------------------------------------------------------------------------------------------

    EXEC EN_GuardaDocumentosPorVersion @idVersion,
                                       @idInstanciaEntregable,
                                       @idUsuario,
                                       @idContrato;
END;
