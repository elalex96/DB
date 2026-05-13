-- =============================================
-- Author:		Manuel CD
-- Create date: 18-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_FormaPago 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdCFDIMetodoPago
      ,Clave
      ,Concepto
	 FROM FI_CFDIMetodoPago
END

