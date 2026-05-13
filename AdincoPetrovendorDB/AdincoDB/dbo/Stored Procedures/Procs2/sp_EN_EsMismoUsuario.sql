-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019
-- Description:Crea excepciones para los responsables de una instancia
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_EsMismoUsuario] 
    @IdContrato INT,
    @IdUsuario INT,
    @IdInstanciaEntregable INT
AS
BEGIN

DECLARE @IdContratoEntregable	INT	=	0,@CountRevisores INT	=	0, @IsUsuarioElab	INT =	0,	@IsUsuarioRev	INT	=	0,	@IsUsuarioApro	INT =	0,@EsMismoUsuario BIT = 0;

SELECT	@IdContratoEntregable = IdContratoEntregable 
FROM EN_InstanciasEntregable WHERE idInstanciaEntregable	=	@IdInstanciaEntregable

 SELECT	@CountRevisores	=	COUNT(1)
    FROM	dbo.EN_Actividad
    WHERE	IdContratoEntregable	=	@IdContratoEntregable
    AND	EstadoID	=	10001;

	
    IF (@CountRevisores	=	1)
    BEGIN
        SELECT @IsUsuarioElab	=	CASE
										WHEN	exa.ActividadIDExcepcion	IS	NOT	NULL	
										THEN	exa.idUsuario
										ELSE	a.idUsuario
									END
        FROM	dbo.EN_Actividad	a

        LEFT	JOIN	dbo.EN_ExcepcionesActividad	exa 
			ON	a.ActividadID	=	exa.ActividadIDExcepcion
            AND	exa.IdInstanciasEntregables	=	@idInstanciaEntregable

        WHERE	a.IdContratoEntregable	=	@IdContratoEntregable
              AND	a.EstadoID	=	10000;


        SELECT	@IsUsuarioRev	=	CASE
										WHEN	exa.ActividadIDExcepcion	IS NOT NULL 
										THEN	exa.idUsuario
										ELSE	a.idUsuario
									END
        FROM	dbo.EN_Actividad	a

        LEFT	JOIN	dbo.EN_ExcepcionesActividad	exa 
			ON	a.ActividadID	=	exa.ActividadIDExcepcion
			AND	exa.IdInstanciasEntregables	=	@idInstanciaEntregable

        WHERE	a.IdContratoEntregable	=	@IdContratoEntregable
              AND	a.EstadoID	=	10001;


        SELECT @IsUsuarioApro = CASE
                                    WHEN	exa.ActividadIDExcepcion IS NOT NULL 
									THEN	exa.idUsuario
                                    ELSE	a.idUsuario
                                END
        FROM dbo.EN_Actividad a

        LEFT	JOIN	dbo.EN_ExcepcionesActividad	exa 
			ON	a.ActividadID	=	exa.ActividadIDExcepcion
			AND	exa.IdInstanciasEntregables	=	@idInstanciaEntregable

        WHERE	a.IdContratoEntregable	=	@IdContratoEntregable
              AND	a.EstadoID	=	10002;
    END;

	IF (@IsUsuarioElab = @IsUsuarioRev AND @IsUsuarioElab = @IsUsuarioApro)
	BEGIN
		SET @EsMismoUsuario	=	1;	
	END

	SELECT  @EsMismoUsuario AS EsMismoUsuario
END

