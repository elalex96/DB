-- =============================================
-- Author:		Mike
-- Create date: 
-- Description:	
-- =============================================
create PROCEDURE [dbo].[sp_VU_ExisteUUID] 
	-- Add the parameters for the stored procedure here
	@UUID nvarchar (MAX) = 0
AS
		DECLARE @ENCONTRADO AS INT
BEGIN
	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Select @ENCONTRADO = COUNT (*) from  FI_Factura  where UUID = @UUID
	IF (@ENCONTRADO > 0 AND LEN(RTRIM (@UUID))>0)
	BEGIN
	SELECT CAST( IDFACTURA  as nvarchar)  AS INSERTADO , 'La factura ya existe con el id ' + CAST( @@IDENTITY  as nvarchar)  as MSG FROM FI_Factura WHERE UUID = @UUID 
	END
	ELSE
	SELECT 0 AS INSERTADO , 'La factura NO existe'  as MSG  
    -- Insert statements for procedure here
	
END
