USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MPY_MM_PCN_ConsultarPCN_ValoresEncabezado]    Script Date: 08/08/2022 10:49:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 14/04/2018
-- Description:	Agregue nuevos columnas a la consulta TipoMaterial, IdTipoNacionalidad, IdTipoCriterio, IdCatalogoHidrocarburos y si es nueva se calcula el valor factura segun 
---el tipo de cambio del pedido a USD si lo requiere
-- =============================================
ALTER PROCEDURE [dbo].[SP_MPY_MM_PCN_ConsultarPCN_ValoresEncabezado] --3829
 
@IdAceptacionPedidoDetalle int
 
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @COUNTIdValoresEnPesosPedidoDetalle INT 
	DECLARE @IdTipoMaterialPedidoDetalle INT 
	
    

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

		DECLARE @ValorFactura MONEY;
		SELECT 
		@ValorFactura = (CASE WHEN APD.IdMoneda <> 'MXN' THEN 
		        ROUND(
                ((SELECT TipoCambio FROM dbo.GetTipoCambioActual(1, APD.Creado))
                         * APD.PrecioUnitario
                ) * (APD.Cantidad),
                2
            )
		ELSE   
		 (ISNULL(APD.PrecioUnitario,0)* ISNULL(APD.Cantidad,0))  
		END)
		FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD
		WHERE APD.IdAceptacionPedidoDetalle=  @IdAceptacionPedidoDetalle;
		
		INSERT INTO MPY_MM_PCN_ValoresPesos([IdAceptacionPedidoDetalle],[VNMO_SueldoNacional],[VMO_Sueldo],[CreadoEl], [IdTipoMaterialServicio], ValorFactura)
		VALUES(@IdAceptacionPedidoDetalle,0,0,GETDATE(),@IdTipoMaterialPedidoDetalle,@ValorFactura)

	END 
	ELSE
	BEGIN
		SELECT 
		@ValorFactura = (CASE WHEN APD.IdMoneda <> 'MXN' THEN 
		        ROUND(
                ((SELECT TipoCambio FROM dbo.GetTipoCambioActual(1, APD.Creado))
                         * APD.PrecioUnitario
                ) * (APD.Cantidad),
                2
            )
		ELSE   
		 (ISNULL(APD.PrecioUnitario,0)* ISNULL(APD.Cantidad,0))  
		END)
		FROM dbo.MPY_MM_AceptacionPedidoDetalle AS APD
		WHERE APD.IdAceptacionPedidoDetalle=  @IdAceptacionPedidoDetalle;

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
	 ISNULL(V.ValorFactura,@ValorFactura) AS ValorFactura,	 
	 APD.Detalle AS NombreMaterial
	 FROM dbo.MPY_MM_PCN_ValoresPesos  AS V
	 LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedidoDetalle=V.IdAceptacionPedidoDetalle
	 LEFT JOIN dbo.MM_Material AS M ON M.IdMaterial= APD.IdMaterialVendendor
	 WHERE V.IdAceptacionPedidoDetalle  = @IdAceptacionPedidoDetalle


 
END
