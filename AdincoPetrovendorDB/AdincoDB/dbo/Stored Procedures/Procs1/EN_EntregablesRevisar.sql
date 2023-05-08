
CREATE PROCEDURE [dbo].[EN_EntregablesRevisar] --10090,3--16
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
    DECLARE	@countI	int;

    CREATE	TABLE #Revision
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

	INSERT INTO	#GrupoUsuario	(IdUsuarioGrupo)
	SELECT	IdGrupo	
	FROM	EN_GruposUsuarios
	WHERE	IdUsuario	=	@idUsuario
		AND IdContrato	=	@IdContrato
		AND	Activo	=	1
	UNION 
	SELECT @idUsuario

    INSERT INTO #Revision
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
                ISNULL(ML.MarcoLegal,'')                     AS MarcoLegal,
                E.TituloAnexo                                AS TituloAnexo,
                E.Capitulo                                   AS Capitulo,
                ISNULL(FE.FrecuenciaEntregable,'')			 AS FrecuenciaEntregable,
                ISNULL(R.Regulador,'')						 AS Regulador,
                ISNULL(Et.Etapa,'')							 AS Etapa,
                I.FechaCalculadaEntregaReg
        FROM
            EN_InstanciasEntregable		I

        JOIN	EN_Actividad			A
			ON I.ActividadID = A.ActividadID

        JOIN	dbo.EN_Estado			ES
			ON	A.EstadoID	=	ES.EstadoID

        JOIN	EN_ContratoEntregable	CE
            ON	CE.IdContratoEntregable	=	I.IdContratoEntregable
            AND	CE.IdContrato	=	@idContrato
			AND	CE.Activo	=	1
			AND	I.Activo	=	1
			AND ISNULL(CE.BitNA,0) <> 1

        JOIN	EN_Entregable			E
			ON	CE.IdEntregable	=	E.IdEntregable
			AND	E.IsActivo	=	1
			AND E.BITJOA = 0
					
		JOIN	#GrupoUsuario	GU
		ON	A.idUsuario	=	GU.IdUsuarioGrupo

		LEFT JOIN	EN_MarcoLegal			ML
			ON	E.IdMarcoLegal	=	ML.IdMarcoLegal

        LEFT JOIN	EN_FrecuenciaEntregable	FE
			ON E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable

        LEFT JOIN	CO_Regulador			R
			ON E.IdRegulador	=	R.IdRegulador

		LEFT JOIN		dbo.EN_Etapa			ET
			ON E.IdEtapa = ET.IdEtapa

		LEFT	JOIN	dbo.EN_ExcepcionesActividad	EXAR
			ON	A.ActividadID	=	EXAR.ActividadIDExcepcion
			AND	I.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

		LEFT	JOIN	#GrupoUsuario		UXR
			ON	EXAR.idUsuario	=	UXR.IdUsuarioGrupo
        WHERE
            (
                A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)		--	@idUsuario
                AND	EXAR.IdInstanciasEntregables	IS	NULL
                AND	A.EstadoID	=	10001
            )
            OR 
            (
                EXAR.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
                AND	EXAR.IdInstanciasEntregables	IS	NOT	NULL
                AND	EXAR.EstadoID	=	10001
            ) 
                    /*UNION
                    SELECT
                            E.IdEntregable          AS idEntregable,
                            CE.IdContratoEntregable AS idContratoEntregable,
                            I.idInstanciaEntregable AS idinstanciaEntregable,
                            E.DocumentoEntregable   AS DocumentoEntregable,
                            FechasLimiteAprobacion  AS FechasLimiteAprobacion,
                            E.Consecutivo           AS Consecutivo,
                            ''                      AS MarcoLegal,
                            E.TituloAnexo           AS TituloAnexo,
                            E.Capitulo              AS Capitulo,
                            ''                      AS FrecuenciaEntregable,
                            ''                      AS Regulador,
                            ''                      AS Etapa,
                            I.FechaCalculadaEntregaReg
                    FROM
                            EN_InstanciasEntregable     I
                        JOIN	EN_Actividad                A
							ON	I.ActividadID	=	A.ActividadID

                        JOIN	dbo.EN_Estado               ES
							ON	A.EstadoID	=	ES.EstadoID

                        JOIN	EN_ContratoEntregable       CE
							ON	CE.IdContratoEntregable	=	I.IdContratoEntregable
							AND	CE.IdContrato = @idContrato

                        JOIN	EN_Entregable               E
							ON	CE.IdEntregable	=	E.IdEntregable

                        JOIN	AP_Usuario                  U
							ON	A.idUsuario	=	U.UsuarioID
                        
                        LEFT JOIN	dbo.EN_ExcepcionesActividad	EXAR
							ON	A.ActividadID	=	EXAR.ActividadIDExcepcion
                            AND	I.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

                        LEFT JOIN	dbo.AP_Usuario			UXR
							ON	EXAR.idUsuario	=	UXR.UsuarioID
                    
                    WHERE
                            (
                                A.idUsuario	=	@idUsuario
                                AND	EXAR.IdInstanciasEntregables	IS	NULL
                                AND	A.EstadoID	=	10001
                                AND	E.IsActivo	=	1
                                AND	CE.Activo	=	1
                                AND	E.BitInterno	=	1
                            )
                            OR 
                                (
                                    EXAR.idUsuario	=	@idUsuario
                AND	EXAR.IdInstanciasEntregables	IS	NOT	NULL
                                    AND	EXAR.EstadoID = 10001
                                    AND	E.IsActivo	=	1
                                    AND	CE.Activo	=	1
                                    AND	E.BitInterno	=	1
                                ); */



       SELECT @countI= MAX(id) FROM
            #Revision;

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
            #Revision
        ORDER BY
            FechasLimiteAprobacion ASC;
    END;