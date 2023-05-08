
-- =============================================
-- Author:		Mike
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VU_ExisteUUID] --'B193dD46C-13EA-46E7-A6F5-842BDEA45BB7'
	---'0CD74C99-AB1E-428B-978KKD-121A6A97292B'
	-- Add the parameters for the stored procedure here
	---- exec  sp_VU_ExisteUUID 'B193D46C-13EA-46E7-A6F5-832BDEA45BB9'
	@UUID nvarchar (MAX) = 0
AS
		DECLARE @ENCONTRADO AS INT
BEGIN
	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Select @ENCONTRADO = COUNT (IdFactura) from  FI_Factura  where UUID = @UUID
	IF (@ENCONTRADO > 0 AND LEN(RTRIM (@UUID))>0)
	BEGIN
		SELECT CAST( IDFACTURA  as nvarchar)  AS INSERTADO , 'La factura PETROVENDOR ya existe  con el id ' + CAST( IDFACTURA  as nvarchar)  as MSG FROM FI_Factura WHERE UUID = @UUID AND IsEliminado IS NULL
	END
	ELSE
	BEGIN
		 
		Select @ENCONTRADO = COUNT (IdFactura) from  Adinco.dbo.FI_Factura   WHERE UUID = @UUID
		IF (@ENCONTRADO > 0 AND LEN(RTRIM (@UUID))>0)
			BEGIN
				SELECT CAST( IDFACTURA  as nvarchar)  AS INSERTADO , 'La factura ADINCO ya existe con el id ' + CAST( IDFACTURA  as nvarchar)  as MSG FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID
            END
        ELSE 
			BEGIN
			  SELECT 0 AS INSERTADO , 'La factura NO existe'  as MSG  
			END 
	END 
	
    -- Insert statements for procedure here
	
END



