CREATE PROCEDURE [dbo].[sp_JOA_ModificaContratosEntregables]
    @idUsuario INT,
	@idContrato INT,
	@idSocio INT,
	@idEntregable INT,
	@IdArea	INT,
	@FechaLimiteRegulador DATE,
	@ContieneFecha	INT,
	@IdUsuarioElaborador INT,
	@IdFrecuenciaEntregable INT,
	@Accountable varchar(300),
	@AccountableComplience varchar(300),
	@Sensible INT

AS
BEGIN
    SET NOCOUNT ON;
	CREATE TABLE #ContratosEntregables
	(
		Id int identity (1,1),	
		IdContratoEntregable	INT,
		IdContrato INT,
		IdEntregable INT,
		GeneroFlujo BIT
	);

	DECLARE @NombreArea varchar(300)='', @IdCont INT = 0, @IdCE INT = 0;

	INSERT INTO #ContratosEntregables(IdContratoEntregable,IdContrato,IdEntregable,GeneroFlujo )
	SELECT IdContratoEntregable,IdContrato,IdEntregable, 0 
	FROM 
		EN_ContratoEntregable C
	WHERE 
	IdEntregable	=	@idEntregable

	SELECT @NombreArea = NombreArea FROM EN_Area WHERE idArea	=	@IdArea;


	---------------Areas---------------
	INSERT INTO EN_Area(NombreArea,idContrato,CreadoPor,CreadoEn,Activo)
	SELECT 
				@NombreArea,CE.IdContrato,@idUsuario,GETDATE(),1
	FROM 
		#ContratosEntregables CE
	LEFT JOIN
			EN_Area	A
		ON	CE.IdContrato = A.idContrato
		AND A.NombreArea	=	@NombreArea
	WHERE
		A.idArea IS NULL
	

	UPDATE CE
		SET CE.IdArea	=	A.idArea,
			CE.Accountable	=	@Accountable,
			CE.AccountableCompliance	=	@AccountableComplience,
			ce.ContieneInformacionSensible	=	@Sensible
	FROM 
		#ContratosEntregables C
	JOIN
		EN_ContratoEntregable	CE
		ON C.IdContratoEntregable	=	CE.IdContratoEntregable
	JOIN
		EN_Area	A
		ON	CE.IdContrato = A.idContrato
		AND A.NombreArea	=	@NombreArea

	---------
--------------------------
	--------Usuario responsable--------
	IF(@IdUsuarioElaborador > 0)
	BEGIN
		EXECUTE [sp_JOA_AgregaUsuarioElaborador] @idUsuario,@idContrato,@idSocio,@idEntregable,@IdUsuarioElaborador;

		declare @i int = 1;

		WHILE((SELECT COUNT (1) FROM #ContratosEntregables WHERE GeneroFlujo	=	0) > 0)
			BEGIN
				SELECT @IdCont  = IdContrato, @IdCE =IdContratoEntregable FROM #ContratosEntregables WHERE Id	=	@i;
				
				EXECUTE [sp_EN_GeneraFlujoContratoEntregable]@IdCE,@idUsuario,@IdCont;


				UPDATE
					#ContratosEntregables
				SET 
					GeneroFlujo = 1
				 WHERE Id	=	@i;

				SET	@i = @i+1;
			END
	END
	-----------------------------------
	---------------FECHAS--------------
	IF(@ContieneFecha	=	1)
	BEGIN
		UPDATE
			CE
		SET
			FechaLimiteEntrega	= @FechaLimiteRegulador,
			FechaLimiteEntregaRegulador	= @FechaLimiteRegulador
		FROM 
			#ContratosEntregables C
		JOIN
			EN_ContratoEntregable	CE
			ON C.IdContratoEntregable	=	CE.IdContratoEntregable;

	EXECUTE [sp_JOA_GeneraInstancias]
										@idUsuario ,
										@idContrato ,
										@idSocio ,
										@idEntregable ,
										@FechaLimiteRegulador ,
										@IdUsuarioElaborador ,
										@IdFrecuenciaEntregable 
	END
	-----------------------------------

	
END


