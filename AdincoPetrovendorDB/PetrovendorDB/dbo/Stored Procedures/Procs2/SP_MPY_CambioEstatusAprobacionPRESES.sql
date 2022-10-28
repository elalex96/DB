CREATE PROCEDURE [dbo].[SP_MPY_CambioEstatusAprobacionPRESES]
	@IdPRESES INT,
	@IdEstatus INT,
	@IdUsuario INT,
	@Justificacion VARCHAR(5000)
AS
BEGIN

	SET NOCOUNT ON;

	declare @matDocGR			VARCHAR(50),
			@ReferenceNumber	VARCHAR(50),
			@GRNumber			VARCHAR(50),
			@PO					VARCHAR(100),
			@IdEstatusSAP INT

	select	@ReferenceNumber		=	SAPSESNumber, 
			@GRNumber				=	MatDocN ,
			@PO						= SAPPONumber,
			@IdEstatusSAP = IdEstatus
	from	adinco..CO_SAPPRESES 
	where	IdPreses				=	@IdPRESES

	

	--Verificar si la proforma está aprobada
	IF EXISTS (
		SELECT 1
		FROM Adinco..CO_SAPSES
		WHERE RTRIM(LTRIM(PO_SAPNumer)) = RTRIM(LTRIM(@PO)) AND
		RTRIM(LTRIM(SESReferenceNumber)) = RTRIM(LTRIM(@ReferenceNumber))
	)
	OR EXISTS (
		SELECT 1
		FROM Adinco..CO_SAPGR
		WHERE RTRIM(LTRIM(PO_SAPNumber)) =  RTRIM(LTRIM(@PO)) AND
		RTRIM(LTRIM(GRReferenceNumber)) = RTRIM(LTRIM(@ReferenceNumber))
	)
	BEGIN
	
			UPDATE Adinco.dbo.CO_SAPPRESES 
			SET		IdEstatus		= @IdEstatus,
					Justificacion	= @Justificacion,
					ModificadoPor	= @IdUsuario,
					ModificadoEl	= GETDATE(),
					MatDocN = CASE WHEN ISNULL(MatDocN,'') = '' THEN MatDocN ELSE @GRNumber END
			FROM Adinco.dbo.CO_SAPPRESES PRO 
			WHERE	IdPRESES		= @IdPRESES

			SELECT 'SUCCESS';

			select	@ReferenceNumber		=	SAPPONumber, 
					@GRNumber				=	MatDocN 
			from	adinco..CO_SAPPRESES 
			where	IdPreses				=	@IdPRESES
			
			exec adinco..p_MPY_CO_SAPPRESES_Bitacora_Ins 
				@ReferenceNumber,
				@GRNumber,
				@IdUsuario,
				@IdPreses,
				@IdEstatus,
				@Justificacion

	END
	ELSE
	BEGIN
		-- SI ESTA EN APROBACION Y ES UN RECHAZO EL CAMBIO DE ESTATUS
		IF(@IdEstatusSAP = 1   AND @IdEstatus = 3
		)
		BEGIN
			UPDATE Adinco.dbo.CO_SAPPRESES 
			SET		IdEstatus		= @IdEstatus,
					Justificacion	= @Justificacion,
					ModificadoPor	= @IdUsuario,
					ModificadoEl	= GETDATE()
			FROM Adinco.dbo.CO_SAPPRESES PRO 
			WHERE	IdPRESES		= @IdPRESES

			SELECT 'SUCCESS'	

			exec adinco..p_MPY_CO_SAPPRESES_Bitacora_Ins 
				@ReferenceNumber,
				@GRNumber,
				@IdUsuario,
				@IdPreses,
				@IdEstatus,
				@Justificacion
		END
	END
	
END



