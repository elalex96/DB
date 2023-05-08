-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ExisteSubcontratistaRC] 
	-- Add the parameters for the stored procedure here
	@RFC nvarchar(MAX) 

AS
DECLARE @ENCONTRADOS AS INT
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SELECT    @ENCONTRADOS = count  (*)  
	FROM            S_Proveedor S
	WHERE UPPER(RTRIM(S.RFC)) =UPPER(RTRIM(@RFC))
	
	IF (@ENCONTRADOS > 0) 
		SELECT        IdProveedor, RazonSocial
		FROM            S_Proveedor S
		WHERE UPPER(RTRIM(S.RFC)) =UPPER(RTRIM(@RFC))
	ELSE
		SELECT  0 AS IdSubcontratista, 'NO EXISTE' AS RazonSocial
END

