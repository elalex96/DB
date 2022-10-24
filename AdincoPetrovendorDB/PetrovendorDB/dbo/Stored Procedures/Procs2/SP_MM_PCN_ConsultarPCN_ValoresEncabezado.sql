USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_PCN_ConsultarPCN_ValoresEncabezado]    Script Date: 20/10/2022 12:23:40 p. m. ******/
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
-- Author:		Alexander Gomez
-- Create date: 04/03/2019
-- Description:	Modifiquer la consulta ya que anteriormente no se contemplaba que se puede modificar la cantidad del pedido y por lo cual el valor factura cambio
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 24/09/2019
-- Description:	Redonde a 3 digitos del PCN segun la SE
-- =============================================
-- Author:  Alexander Gomez  
-- Create date: 01/02/2021
-- Description: Se resta un dia menos a la fecha de tipo de cambio
-- =============================================  
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 18/05/2022
-- Description: truncado a 3 digitos sin redondeo del PCN segun la SE Y optimizacion
-- =============================================
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 18/10/2022
-- Description: se establece que el valor facturado es el valor guardado en la aceptacion, si este monto no existe se toma el del pedido (WDEA)
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_PCN_ConsultarPCN_ValoresEncabezado]  
@IdAceptacionPedidoDetalle int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @COUNTIdValoresEnPesosPedidoDetalle INT 
	DECLARE @IdTipoMaterialPedidoDetalle INT 
	DECLARE @ValorFactura MONEY;
	DECLARE @EXISTEVALORFACTURA FLOAT;
	DECLARE @IdMonedaNacional INT = 1; 
    

	SET @COUNTIdValoresEnPesosPedidoDetalle =(SELECT COUNT(IdValoresEnPesosPedidoDetalle) FROM MM_PCN_ValoresPesos WHERE IdAceptacionPedidoDetalle=@IdAceptacionPedidoDetalle);

	/*BUSCAR EL ID DEL TIPO DE MATERIAL DEL VENDEDOR*/
		SELECT 
			@IdTipoMaterialPedidoDetalle=M.IdTipoCatalogoMaestro
		FROM dbo.MM_AceptacionPedidoDetalle APD
			JOIN dbo.MM_PedidoDetalle AP 
				ON AP.IdPedidoDetalle=APD.IdPedidoDetalle
				AND APD.IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle
			JOIN dbo.MM_Material AS M 
				ON M.IdMaterial=AP.IdMaterialVendedor;

		/*CALCULAR VALOR FACTURA DEL LA PARTIDA ACTUAL*/
		/*VALIDAR MONEDA MXN Y USD*/

		SET @EXISTEVALORFACTURA = (SELECT ValorFactura FROM MM_PCN_ValoresPesos WHERE IdAceptacionPedidoDetalle=@IdAceptacionPedidoDetalle);

		IF ISNULL(@EXISTEVALORFACTURA,0) = 0
		BEGIN

			SELECT 
			@ValorFactura = (CASE WHEN PD.IdMoneda <> @IdMonedaNacional THEN 
					ROUND(
					(ISNULL(
						(
							SELECT TC.TipoCambio
							FROM Adinco.dbo.CO_TipoCambioDiario TC
							WHERE DAY(TC.Fecha) = DAY(DATEADD(DAY,-1,GETDATE()))
								AND MONTH(TC.Fecha) = MONTH(DATEADD(DAY,-1,GETDATE()))
								AND YEAR(TC.Fecha) = MONTH(DATEADD(DAY,-1,GETDATE()))
								AND TC.IdMoneda = @IdMonedaNacional
						),
						(
							SELECT TipoCambio FROM dbo.GetTipoCambioActual(@IdMonedaNacional, DATEADD(DAY,-1,GETDATE()))
						)
							) * ISNULL(APD.PrecioUnitario,PD.PrecioUnitario)
					) * (APD.Cantidad),
					4
				)
			ELSE   
			 (ISNULL(APD.PrecioUnitario,ISNULL(PD.PrecioUnitario,0))* ISNULL(APD.Cantidad,0))  
			END)
			FROM dbo.MM_AceptacionPedidoDetalle APD
				JOIN dbo.MM_PedidoDetalle PD 
					ON APD.IdPedidoDetalle = PD.IdPedidoDetalle	
					AND APD.IdAceptacionPedidoDetalle =  @IdAceptacionPedidoDetalle
				JOIN MM_Pedido AS P
					ON PD.IdPedido = P.IdPedido
				LEFT JOIN dbo.MM_PedidoTipoCambio AS PTC
					ON PD.IdPedido = PTC.IdPedido;

		END
		ELSE
		BEGIN

			SET @ValorFactura = @EXISTEVALORFACTURA;

		END;

	
	IF @COUNTIdValoresEnPesosPedidoDetalle = 0 
	BEGIN 

		
		
		INSERT INTO MM_PCN_ValoresPesos([IdAceptacionPedidoDetalle],[VNMO_SueldoNacional],[VMO_Sueldo],[CreadoEl], [IdTipoMaterialServicio], ValorFactura)
		VALUES(@IdAceptacionPedidoDetalle,0,0,GETDATE(),@IdTipoMaterialPedidoDetalle,@ValorFactura)

	END
	ELSE
	BEGIN

		UPDATE dbo.MM_PCN_ValoresPesos
		SET ValorFactura = @ValorFactura
		WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle;

	END;
		 
	 SELECT 
		 V.IdValoresEnPesosPedidoDetalle, 
		 V.VNMO_SueldoNacional, 
		 V.VMO_Sueldo, 
		 CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar),1,5) AS nvarchar) AS PCN,  
		 ISNULL(V.IdTipoMaterialServicio,0) AS TipoMaterial, 
		 ISNULL(V.IdTipoNacionalidad,0) AS IdTipoNacionalidad, 
		 ISNULL(V.IdTipoCriterio,0) AS IdTipoCriterio,
		 ISNULL(V.IdCatalogoHidrocarburos,0) AS IdCatalogoHidrocarburos,
		 ISNULL(V.FraccionArancelaria,'') AS FraccionArancelaria,
		 ISNULL(V.ValorFactura,0) AS ValorFactura,	 
		 CASE WHEN DATALENGTH(M.DescripcionCorta) > 200 THEN 
			SUBSTRING(M.DescripcionCorta, 0,200)+'...'
		 ELSE 
		   M.DescripcionCorta
		 END AS NombreMaterial
	 FROM MM_PCN_ValoresPesos  AS V
		 LEFT JOIN MM_AceptacionPedidoDetalle AS APD 
			ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
			AND V.IdAceptacionPedidoDetalle  = @IdAceptacionPedidoDetalle
		 JOIN dbo.MM_PedidoDetalle AS PD 
			ON PD.IdPedidoDetalle= APD.IdPedidoDetalle
		 LEFT JOIN dbo.MM_Material AS M 
			ON PD.IdMaterialVendedor = M.IdMaterial;

END