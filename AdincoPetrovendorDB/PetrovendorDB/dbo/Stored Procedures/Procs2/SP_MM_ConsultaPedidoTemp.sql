-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Oferta  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPedidoTemp]
	-- Add the parameters for the stored procedure here
	@IdPeticionDetalle NVARCHAR(MAX)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @TABLA NVARCHAR(MAX)=''

	    CREATE TABLE #PETICION_PEDIDO_IDS(IdPeticionPedidoDetalle int, IdRow int)
		CREATE TABLE #DETALLE_PEDIDO(IdPeticionPedidoDetalle INT,Material NVARCHAR(MAX) ,Disponibilidad INT, PrecioUnitario FLOAT, Subtotal FLOAT, NombreProveedor NVARCHAR(MAX), IdRow INT)
		----DROP TABLE #PETICION_PEDIDO_IDS
		DECLARE @xml xml, @str NVARCHAR(MAX), @delimiter varchar(10)
		SET @str = @IdPeticionDetalle
		SET @delimiter = ','
		SET @xml = cast(('<X>'+replace(@str, @delimiter, '</X><X>')+'</X>') as xml)

		INSERT INTO #PETICION_PEDIDO_IDS
		SELECT C.value('.', 'varchar(10)') as value, ROW_NUMBER() OVER(ORDER BY C.value('.', 'varchar(10)')  ASC) AS Row#
		FROM @xml.nodes('X') as X(C)



		DECLARE @COLUMNS_ALL INT = (SELECT COUNT(IdPeticionPedidoDetalle) FROM #PETICION_PEDIDO_IDS)
		DECLARE @COLUMN INT = 1
		SET @TABLA =@TABLA+'<br><br><h5 class="text-black bold inline m-l-10">MATERIALES AGREGADOS</h5><br>'
		SET @TABLA =@TABLA+ '<table class="table table-flip-scroll cf table-bordered" style="cursor: pointer" id="tb_Pedido"  data-pedido="'+CAST(@IdPeticionDetalle AS NVARCHAR(MAX))+'"'
		SET @TABLA = @TABLA+'<thead class="cf">'
	
		SET @TABLA = @TABLA + '<tr>'
		SET @TABLA = @TABLA+'<th>Material</th>'
		SET @TABLA = @TABLA+'<th>Cantidad</th>' 
		SET @TABLA = @TABLA+'<th>PU</th>' 
		SET @TABLA = @TABLA+'<th>Subtotal</th>' 
		SET @TABLA = @TABLA+'<th>Proveedor</th>'
	    SET @TABLA = @TABLA+'</thead>'
		SET @TABLA = @TABLA+'<tbody>'
		WHILE @COLUMN <= @COLUMNS_ALL 

			BEGIN 
				INSERT INTO #DETALLE_PEDIDO
				SELECT POD.IdPeticionOfertaDetalle,M.DescripcionCorta,POD.Disponibilidad, POD.PrecioUnitario, (POD.PrecioUnitario * POD.Disponibilidad ) AS Subtotal, P.Razonsocial + P.RegimenCapital AS NombreProveedor, @COLUMN
				FROM MM_PeticionOfertaDetalle AS POD
				INNER JOIN MM_MATERIAL AS M ON M.IdMaterial = POD.IdMaterial
				INNER JOIN S_Proveedor AS P ON P.IdProveedor = POD.IdProveedorVenta
				WHERE [IdPeticionOfertaDetalle] IN (SELECT IdPeticionPedidoDetalle FROM  #PETICION_PEDIDO_IDS WHERE IdRow =@COLUMN)


				
				SET @TABLA = @TABLA + '<tr id="'+CAST(@COLUMN AS NVARCHAR(MAX))+'" data-Idpedido="'+CAST((SELECT IdPeticionPedidoDetalle FROM  #PETICION_PEDIDO_IDS WHERE IdRow =@COLUMN) AS NVARCHAR(MAX))+'">' 
					SET @TABLA = @TABLA + '<td>' 
					SET @TABLA =  @TABLA+CAST((SELECT Material FROM #DETALLE_PEDIDO WHERE IdRow = @COLUMN)  AS NVARCHAR(MAX))
					SET @TABLA = @TABLA + '</td>' 
					SET @TABLA = @TABLA + '<td>' 
					SET @TABLA =  @TABLA+CAST((SELECT Disponibilidad FROM #DETALLE_PEDIDO WHERE IdRow = @COLUMN)  AS NVARCHAR(MAX))
					SET @TABLA = @TABLA + '</td>' 
					SET @TABLA = @TABLA + '<td>' 
					SET @TABLA =  @TABLA+CAST((SELECT PrecioUnitario FROM #DETALLE_PEDIDO WHERE IdRow = @COLUMN)  AS NVARCHAR(MAX))
					SET @TABLA = @TABLA + '</td>' 
					SET @TABLA = @TABLA + '<td>' 
					SET @TABLA =  @TABLA+CAST((SELECT Subtotal FROM #DETALLE_PEDIDO WHERE IdRow = @COLUMN)  AS NVARCHAR(MAX))
					SET @TABLA = @TABLA + '</td>' 
					SET @TABLA = @TABLA + '<td>' 
					SET @TABLA =  @TABLA+CAST((SELECT NombreProveedor FROM #DETALLE_PEDIDO WHERE IdRow = @COLUMN)  AS NVARCHAR(MAX))
					SET @TABLA = @TABLA + '</td>' 
				SET @TABLA = @TABLA + '</tr>'
				SET @COLUMN = @COLUMN +1


			END 
			SET @TABLA = @TABLA+'</tbody>'
			SET @TABLA = @TABLA+'</table>'

			SELECT @TABLA
		
END

