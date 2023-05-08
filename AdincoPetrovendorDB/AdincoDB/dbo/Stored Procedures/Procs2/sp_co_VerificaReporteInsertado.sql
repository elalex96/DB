-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_co_VerificaReporteInsertado]
	-- Add the parameters for the stored procedure here
	@idContrato nvarchar(max),
	@fecha nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

    Select Count (idContrato)
	from PC_CruceProduccionVentas
	where idcontrato=@idcontrato
	and fechaReporte=@fecha
END

