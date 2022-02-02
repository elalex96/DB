CREATE PROCEDURE [dbo].[SP_MPY_CambioEstatusAprobacionPRESES]
	-- Add the parameters for the stored procedure here
	@IdPRESES INT,
	@IdEstatus INT,
	@IdUsuario INT,
	@Justificacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @matDocGR varchar(20)


	select @matDocGR = gr.MatDocN
	from Adinco..CO_SAPGR gr
	inner join Adinco..CO_SAPPRESES  pr on pr.SAPPONumber = gr.PO_SAPNumber 									
	where pr.IdPRESES		= @IdPRESES and
	gr.GRReferenceNumber = pr.SAPSESNumber


    -- Insert statements for procedure here
	UPDATE Adinco.dbo.CO_SAPPRESES 
	SET		IdEstatus		= @IdEstatus,
			Justificacion	= @Justificacion,
			ModificadoPor	= @IdUsuario,
			ModificadoEl	= GETDATE(),
			MatDocN = @matDocGR
	WHERE	IdPRESES		= @IdPRESES

	SELECT 'SUCCESS'

	declare		@ReferenceNumber	varchar(20),
				@GRNumber			varchar(20)

				--use adinco
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

