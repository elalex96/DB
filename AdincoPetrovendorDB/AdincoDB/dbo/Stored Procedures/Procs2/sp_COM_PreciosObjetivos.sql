-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_COM_PreciosObjetivos 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0, 
	@MesReporte date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdContrato, Mes, IdTipoHidrocarburo, PrecioUnitario, CreadoPor, CreadoEl, ModificadoPor, ModificadoEl
FROM            COM_PreciosObjetivosHidroCarburos
WHERE        (IdContrato = @IdContrato) AND (Mes = @MesReporte)
END
