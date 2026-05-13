-- =============================================
-- Author:		Reyna Olvera
-- Create date: 16042020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_GuardaActividadesEntregablesProcesos]--10061,3,285713
    @idUsuario INT,
    @idContrato INT,
	@idInstanciaActividad	INT,
	@IdEntregable	INT
AS
BEGIN
    SET NOCOUNT ON;
	CREATE TABLE #InstanciaEntregable(
			FechasLimiteElaboracion DATE,
			FechasLimiteRevision DATE,
			FechasLimiteAprobacion DATE,
			FechaEnvioMensajeAtrasoRevision DATE,
			idFrecuencua INT,
			IdContratoEntregable INT,
			ContieneAjusteFechas INT,
			CorreoEnviado BIT,
			ActividadID INT,
			FechaCalculadaEntregaReg DATE,
			FechaInicioElaboracion DATE,
			BitContieneAcuse BIT)

	DECLARE @IdActividad	INT = 0,
			@FechaFinInstanciaActividad DATE,
			@idActividadElab INT	=	0,
			@IdContratoEntregable INT,
			@idFrecuencua	INT;

	Select @IdContratoEntregable	=	
	IdContratoEntregable,
		@idFrecuencua	=	
		IdFrecuenciaEntregable
	FROM 
		EN_ContratoEntregable	CE
	JOIN
		EN_Entregable	E
		ON CE.IdEntregable	=	E.IdEntregable
		AND CE.IdContrato	=	@idContrato
	WHERE
		CE.IdEntregable	=	@IdEntregable
		AND	CE.IdContrato	=	@idContrato
		

	SELECT @idActividadElab = 
	ISNULL(ActividadID,0)
    FROM dbo.EN_Actividad
    WHERE IdContratoEntregable = @IdContratoEntregable --16622
            AND EstadoID = 10000; --Para elaboración o corrección

IF(@idActividadElab	>	0)
BEGIN
	SELECT @FechaFinInstanciaActividad	=	
	FechaActividad 
	FROM
		EN_InstanciasActividades
	WHERE idInstanciaActividad	=	@idInstanciaActividad;


	INSERT INTO EN_ActividadesEntregables(IdActividad,IdEntregable,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,Activo)
	SELECT
		IdActividad,@IdEntregable,@idUsuario,GETDATE(),@idUsuario,GETDATE(),1
	FROM
		EN_InstanciasActividades
	WHERE
		idInstanciaActividad	=	@idInstanciaActividad

--******************
--SE LLEVA A CABO EL CALULO DE ENTREGABLE Y SE GUARDA LA INSTANCIA
--******************

	INSERT INTO #InstanciaEntregable (
			FechasLimiteAprobacion ,
			idFrecuencua ,
			IdContratoEntregable ,
			ContieneAjusteFechas ,
			CorreoEnviado ,
			ActividadID ,
			FechaCalculadaEntregaReg ,
			BitContieneAcuse )
			VALUES (@FechaFinInstanciaActividad,@idFrecuencua,@IdContratoEntregable,@idInstanciaActividad,0,@idActividadElab,@FechaFinInstanciaActividad,0)


	UPDATE IE
	SET  FechasLimiteRevision	=	Adinco.dbo.FN_EN_RestaDiasHabiles(
								FechasLimiteAprobacion,
								DiasAprobacion)
	FROM #InstanciaEntregable IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable


	UPDATE IE
	SET  FechasLimiteElaboracion	=	Adinco.dbo.FN_EN_RestaDiasHabiles(
										FechasLimiteRevision,
										DiasRevision)
	FROM #InstanciaEntregable IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable


	UPDATE IE
	SET  FechaInicioElaboracion	=	Adinco.dbo.FN_EN_RestaDiasHabiles(
										FechasLimiteElaboracion,
										DiasElaboracion)
	FROM #InstanciaEntregable IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable


	UPDATE IE
	SET  FechaEnvioMensajeAtrasoRevision	=	Adinco.dbo.FN_EN_RestaDiasHabiles(
										FechaInicioElaboracion,
										DiasAlerta)
	FROM #InstanciaEntregable IE
	JOIN
		EN_ContratoEntregable	CE
		ON IE.IdContratoEntregable	=	CE.IdContratoEntregable

		--select * from #InstanciaEntregable
	INSERT INTO EN_InstanciasEntregable
	(FechasLimiteElaboracion,
	FechasLimiteRevision,
	FechasLimiteAprobacion,
	FechaEnvioMensajeAtrasoRevision,
	idFrecuencua,
	IdContratoEntregable,
	ContieneAjusteFechas,
	CorreoEnviado,
	ActividadID,
	CreadoPor,
	CreadoEn,
	ModificadoPor,
	ModificadoEn,
	Activo,
	FechaCalculadaEntregaReg,
	FechaInicioElaboracion,
	BitContieneAcuse)
SELECT	FechasLimiteElaboracion,
		FechasLimiteRevision ,
		FechasLimiteAprobacion ,
		FechaEnvioMensajeAtrasoRevision ,
		idFrecuencua ,
		IdContratoEntregable ,
		ContieneAjusteFechas ,
		CorreoEnviado ,
		ActividadID ,
		@idUsuario,
		GETDATE(),
		@idUsuario,
		GETDATE(),
		1,
		FechaCalculadaEntregaReg ,
		FechaInicioElaboracion ,
		BitContieneAcuse  FROM #InstanciaEntregable

		INSERT INTO EN_InstanciasEntregables_InstanciaActividad
		(idInstanciaEntregable,
		idInstanciaActividad,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl,
		Activo)
		SELECT	idInstanciaEntregable,
				@idInstanciaActividad,
				@idUsuario,
				GETDATE(),
				@idUsuario,
				GETDATE(),
				1
		FROM
			EN_InstanciasEntregable
		WHERE
			ContieneAjusteFechas	=	@idInstanciaActividad;
		
	UPDATE EN_InstanciasEntregable
	SET
		ContieneAjusteFechas	=	0
	WHERE
			ContieneAjusteFechas	=	@idInstanciaActividad;			
	END;
END;
