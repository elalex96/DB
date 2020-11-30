-- =============================================
-- Author:		Reyna Olvera
-- Create date: 12/04/2018
-- Description:	Extrae las unidades de medida
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraeUnidadesMedidaDiaria]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	    -- Insert statements for procedure here
	SELECT [idUnidadMedida], [Abreviatura] FROM [CO_UnidadMedida] 
	where  Abreviatura='BL' or abreviatura='MMPCD'
END

