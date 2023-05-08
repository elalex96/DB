-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CalculaCuotaFaseExpLic
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0, 
	@Periodo date 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  1150 * AC.SuperficieKm2   from  CO_AreaContractual   AC join 
	co_contrato C on c.IdAreaContractual =    AC.IdAreaContractual
	where C.IdContrato= @IdContrato
	 
	--   @IdContrato, @Periodo
END
