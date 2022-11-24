-- =============================================
-- Author:		Daniel AC
-- Create date: 14/04/2018
-- Description:	Agregue nuevos columnas a la consulta TipoMaterial, IdTipoNacionalidad, IdTipoCriterio, IdCatalogoHidrocarburos y si es nueva se calcula el valor factura segun 
---el tipo de cambio del pedido a USD si lo requiere
-- =============================================
create PROCEDURE [dbo].[SP_MPY_MM_PCN_ConsultarPCN_ValoresEncabezado]  
 
@IdAceptacionPedidoDetalle int
 
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @COUNTIdValoresEnPesosPedidoDetalle INT 
	DECLARE @IdTipoMaterialPedidoDetalle INT 
	DECLARE @ValorFactura MONEY
    

	SET @COUNTIdValoresEnPesosPedidoDetalle =(SELECT COUNT(IdValoresEnPesosPedidoDetalle) FROM MPY_MM_PCN_ValoresPesos WHERE IdAceptacionPedidoDetalle=@IdAceptacionPedidoDetalle)

	
	IF @COUNTIdValoresEnPesosPedidoDetalle = 0 
	BEGIN 

		/*BUSCAR EL ID DEL TIPO DE MATERIAL DEL VENDEDOR*/
		SELECT @IdTipoMaterialPedidoDetalle=M.IdTipoCatalogoMaestro
		FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD
		INNER JOIN dbo.MM_Material AS M ON M.IdMaterial= APD.IdMaterialVendendor
		WHERE APD.IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle

		/*CALCULAR VALOR FACTURA DEL LA PARTIDA ACTUAL*/
		/*VALIDAR MONEDA MXN Y USD*/

		DECLARE @IdMonedaNacional INT = 1;  

		SELECT 
		@ValorFactura = (CASE WHEN APD.IdMoneda <> 'MXN' THEN 
		        ROUND(
                ((SELECT TipoCambio FROM dbo.GetTipoCambioActual(@IdMonedaNacional, APD.Creado))
                         * APD.PrecioUnitario
                ) * (APD.Cantidad),
                2
            )
		ELSE   
		 (ISNULL(APD.PrecioUnitario,0)* ISNULL(APD.Cantidad,0))  
		END)
		FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD
		WHERE APD.IdAceptacionPedidoDetalle=  @IdAceptacionPedidoDetalle
		
		INSERT INTO MPY_MM_PCN_ValoresPesos([IdAceptacionPedidoDetalle],[VNMO_SueldoNacional],[VMO_Sueldo],[CreadoEl], [IdTipoMaterialServicio], ValorFactura)
		VALUES(@IdAceptacionPedidoDetalle,0,0,GETDATE(),@IdTipoMaterialPedidoDetalle,@ValorFactura)

	END 
		 
	 SELECT V.IdValoresEnPesosPedidoDetalle, 
	 V.VNMO_SueldoNacional, 
	 V.VMO_Sueldo, 
	 ISNULL(APD.PCN,0) AS PCN, 
	 ISNULL(V.IdTipoMaterialServicio,0) AS TipoMaterial, 
	 ISNULL(V.IdTipoNacionalidad,0) AS IdTipoNacionalidad, 
	 ISNULL(V.IdTipoCriterio,0) AS IdTipoCriterio,
	 ISNULL(V.IdCatalogoHidrocarburos,0) AS IdCatalogoHidrocarburos,
	 ISNULL(V.FraccionArancelaria,'') AS FraccionArancelaria,
	 ISNULL(V.ValorFactura,0) AS ValorFactura,	 
	 APD.Detalle AS NombreMaterial
	 FROM dbo.MPY_MM_PCN_ValoresPesos  AS V
	 LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedidoDetalle=V.IdAceptacionPedidoDetalle
	 LEFT JOIN dbo.MM_Material AS M ON M.IdMaterial= APD.IdMaterialVendendor
	 WHERE V.IdAceptacionPedidoDetalle  = @IdAceptacionPedidoDetalle


 
END