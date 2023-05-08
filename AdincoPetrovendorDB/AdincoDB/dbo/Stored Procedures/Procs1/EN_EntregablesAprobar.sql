CREATE PROCEDURE [dbo].[EN_EntregablesAprobar] --2,3
    @idUsuario  INT,
    @idContrato INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/04/2018
-- Description:	Para que el usuario pueba ver que archivos tiene que aprobar 
-- =============================================
-- 11/11/2021 MC Ocultar entregables marcados como NA issue 468 entregables  
-- =============================================
    SET NOCOUNT ON;

    CREATE TABLE #Aprobacion
    (
        id                       INT IDENTITY(1, 1),
        idEntregable             INT,
        idContratoEntregable     INT,
        idinstanciaEntregable    INT,
        DocumentoEntregable      VARCHAR(3000),
        FechasLimiteAprobacion   DATE,
        Consecutivo              VARCHAR(300),
        MarcoLegal               VARCHAR(3000),
        TituloAnexo              VARCHAR(5000),
        Capitulo                 VARCHAR(5000),
        FrecuenciaEntregable     VARCHAR(3000),
        Regulador                VARCHAR(300),
        Etapa                    VARCHAR(3000),
        FechaCalculadaEntregaReg DATE
    );

	CREATE TABLE #GrupoUsuario
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        IdUsuarioGrupo int
    );

	DECLARE @countI int;

	INSERT INTO	#GrupoUsuario	(IdUsuarioGrupo)
	SELECT	IdGrupo	
	FROM	EN_GruposUsuarios
	WHERE	IdUsuario	=	@idUsuario
		AND IdContrato	=	@IdContrato
		AND	Activo	=	1
	UNION 
	SELECT @idUsuario

    INSERT INTO #Aprobacion
        (
            idEntregable,
            idContratoEntregable,
            idinstanciaEntregable,
            DocumentoEntregable,
            FechasLimiteAprobacion,
            Consecutivo,
            MarcoLegal,
            TituloAnexo,
            Capitulo,
            FrecuenciaEntregable,
            Regulador,
            Etapa,
            FechaCalculadaEntregaReg
        )
        SELECT
                E.IdEntregable                               AS idEntregable,
                CE.IdContratoEntregable                      AS idContratoEntregable,
                I.idInstanciaEntregable                      AS idinstanciaEntregable,
                E.DocumentoEntregable                        AS DocumentoEntregable,
                FechasLimiteAprobacion                       AS FechasLimiteAprobacion,
                E.Consecutivo                                AS Consecutivo,
                ML.MarcoLegal                                AS MarcoLegal,
                E.TituloAnexo                                AS TituloAnexo,
                E.Capitulo                                   AS Capitulo,
                -- E.Articulo,
                EN_FrecuenciaEntregable.FrecuenciaEntregable AS FrecuenciaEntregable,
                CO_Regulador.Regulador                       AS Regulador,
                ET.Etapa,
                I.FechaCalculadaEntregaReg
        FROM
                EN_InstanciasEntregable     I	(NOLOCK)
            JOIN
                EN_ContratoEntregable       CE	(NOLOCK)
                    ON CE.IdContratoEntregable = I.IdContratoEntregable
					AND CE.IdContrato = @idContrato
					AND CE.Activo = 1
					AND ISNULL(CE.BitNA,0) <> 1
            JOIN
                EN_Actividad                A	(NOLOCK)
                    ON I.ActividadID = A.ActividadID
            JOIN
                dbo.EN_Estado               ES	(NOLOCK)
                    ON A.EstadoID = ES.EstadoID
            INNER JOIN
                EN_Entregable               E	(NOLOCK)
                    ON CE.IdEntregable = E.IdEntregable
					AND E.IsActivo = 1
					AND E.BitJOA	=	0
            INNER JOIN
                EN_MarcoLegal               AS ML	(NOLOCK)
                    ON E.IdMarcoLegal = ML.IdMarcoLegal
            INNER JOIN
                EN_FrecuenciaEntregable
					ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable
            INNER JOIN
                CO_Regulador
                    ON E.IdRegulador = CO_Regulador.IdRegulador
			JOIN	#GrupoUsuario	GU
					ON	A.idUsuario	=	GU.IdUsuarioGrupo
            --INNER JOIN
            --    AP_Usuario                  U
            --        ON A.idUsuario = U.UsuarioID
            JOIN
                dbo.EN_Etapa                ET
                    ON E.IdEtapa = ET.IdEtapa
            --************************************************
            LEFT JOIN
                dbo.EN_ExcepcionesActividad EXAR
                    ON A.ActividadID = EXAR.ActividadIDExcepcion
                        AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables
            LEFT JOIN
                dbo.AP_Usuario              UXR
                    ON EXAR.idUsuario = UXR.UsuarioID
        --************************************************
        WHERE
                A.EstadoID = 10002 -- AND      A.idUsuario     = @idUsuario;
                AND
                    (
--                        A.idUsuario = @idUsuario --********************************
                        EXAR.IdInstanciasEntregables IS NULL
                        AND A.EstadoID = 10002
                    )
                OR --********************************
                    (
                        EXAR.idUsuario = @idUsuario --********************************
                        AND EXAR.IdInstanciasEntregables IS NOT NULL
                        AND EXAR.EstadoID = 10002
                    ) --********************************

        UNION
        SELECT
                E.IdEntregable          AS idEntregable,
                CE.IdContratoEntregable AS idContratoEntregable,
                I.idInstanciaEntregable AS idinstanciaEntregable,
                E.DocumentoEntregable   AS DocumentoEntregable,
                FechasLimiteAprobacion  AS FechasLimiteAprobacion,
                E.Consecutivo           AS Consecutivo,
                ''                      AS MarcoLegal,
                ''                      AS TituloAnexo,
                ''                      AS Capitulo,
                -- E.Articulo,
                ''                      AS FrecuenciaEntregable,
                ''                      AS Regulador,
                ''                      AS Etapa,
                I.FechaCalculadaEntregaReg
        FROM
                EN_InstanciasEntregable     I	(NOLOCK)
            JOIN
                EN_ContratoEntregable       CE	(NOLOCK)
                    ON CE.IdContratoEntregable = I.IdContratoEntregable
                    AND CE.IdContrato = @idContrato
					AND CE.Activo = 1
					AND ISNULL(CE.BitNA,0) <> 1
            JOIN
                EN_Actividad                A	(NOLOCK)
                    ON I.ActividadID = A.ActividadID
            JOIN
                dbo.EN_Estado               ES	(NOLOCK)
                    ON A.EstadoID = ES.EstadoID
            INNER JOIN
                EN_Entregable               E	(NOLOCK)
					ON CE.IdEntregable = E.IdEntregable
					AND E.IsActivo = 1
                    AND E.BitInterno = 1
					AND	E.BitJOA	=	0
			JOIN	#GrupoUsuario	GU
					ON	A.idUsuario	=	GU.IdUsuarioGrupo
            --INNER JOIN
            --    AP_Usuario                  U
            --        ON A.idUsuario = U.UsuarioID
            --************************************************
            LEFT JOIN
                dbo.EN_ExcepcionesActividad EXAR
                    ON A.ActividadID = EXAR.ActividadIDExcepcion
                        AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables
            LEFT JOIN
                dbo.AP_Usuario              UXR
                    ON EXAR.idUsuario = UXR.UsuarioID
        --************************************************
        WHERE
            A.EstadoID = 10002 -- AND      A.idUsuario     = @idUsuario;
            AND
                (
--                    A.idUsuario = @idUsuario --********************************
                    EXAR.IdInstanciasEntregables IS NULL
                    AND A.EstadoID = 10002
                )
            OR --********************************
                (
                    EXAR.idUsuario = @idUsuario --********************************
                    AND EXAR.IdInstanciasEntregables IS NOT NULL
                    AND EXAR.EstadoID = 10002
                ); --********************************

     SELECT @countI= MAX(id) FROM
            #Aprobacion;

        SELECT
            @countI AS countI,
            idEntregable,
            idContratoEntregable,
            idinstanciaEntregable,
            DocumentoEntregable,
            FechasLimiteAprobacion,
            Consecutivo,
            MarcoLegal,
            TituloAnexo,
            Capitulo,
            FrecuenciaEntregable,
            Regulador,
            Etapa,
            FechaCalculadaEntregaReg
        FROM
            #Aprobacion
        ORDER BY
            FechasLimiteAprobacion ASC;

    END;
