CREATE PROCEDURE [dbo].[SP_FI_VU_ExisteUUID_AceptacionFactura]
	-- Add the parameters for the stored procedure here
	
	@UUID nvarchar (MAX) = 0,
	@IdAceptacionPedido int
AS
BEGIN
-- =============================================
-- Author: DANIEL AC 
-- Create date: 08/02/2018
-- Description:	Validar que el UUID no este en la base de datos o si esta sea de igual a la operación actual
-- =============================================
-- Author: Alexander Gomez 
-- Create date: 16/03/2018
-- Description:	agregado el filtro de iseliminado en factura
-- =============================================
-- Author: Daniel AC
-- Create date: 16/03/2018
-- Description:	Se elimina filtro de tipo de pedido para evitar subir doble factura cuando este rechazada
-- =============================================	

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdFactura INT
    DECLARE @UUID_ACTUAL NVARCHAR(MAX)
	DECLARE @ENCONTRADO AS INT

	Select @ENCONTRADO = COUNT (IdFactura) from  FI_Factura  where UUID = @UUID AND IsEliminado IS NULL
	IF (@ENCONTRADO > 0 AND LEN(RTRIM (@UUID))>0)
	BEGIN
		---VALIDAR SI ES EL MISMO DE LA OPERACIIÓN ACTUAL 
		SELECT @IdFactura=IdFactura FROM dbo.MM_AceptacionFactura WHERE IdAceptacionPedido= @IdAceptacionPedido
		SELECT @UUID_ACTUAL=UUID FROM dbo.FI_Factura WHERE IdFactura= @IdFactura

		IF ISNULL(@UUID_ACTUAL,'') = @UUID 
			SELECT 0  AS INSERTADO , 'La factura PETROVENDOR YA EXISTE PERO ES LA MISMA QUE SE ENCUENTRA RESGISTRADA PARA ESTA APROBACIÓN NO. ' +  CAST( IDFACTURA  as nvarchar)  as MSG FROM FI_Factura WHERE UUID = @UUID 
		ELSE 
			SELECT CAST( IDFACTURA  as nvarchar)  AS INSERTADO , 'La factura PETROVENDOR ya existe  con el id ' + CAST( IDFACTURA  as nvarchar)  as MSG FROM FI_Factura WHERE UUID = @UUID 
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
	

	
END
