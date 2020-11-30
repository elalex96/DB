-- =============================================
-- Modificacion:Abel Rivera
-- Create date: 08-03-2018
-- Description: se cambio el idDomicilioEntrega por la concatenacion de del texto del domicilio temporalmente
-- =============================================
-- Author: Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedidoDetalle_MV1_5]
	-- Add the parameters for the stored procedure here
	 
	@IdSolicitudPedido INT,
	@IdContrato    INT = NULL,
	@IdUsuario     INT = NULL,
	@FechaRegistro DATETIME = NULL
  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
		SELECT SPD.IdSolicitudPedidoDetalle,
		 CONCAT(' Descripción: ', MM.DescripcionCorta,
				 ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				 ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				 ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END)	
		 AS DescripcionCorta, 
		 MM.IdMaterial AS IdMaterial,
		 SPD.Cantidad, 
		 SPD.Observaciones, 
		 U.Unidad AS NombreUnidad,
		 CONCAT(D.Calle, ' ',
		  D.NoExterior , ' ', 
		  D.NoInterior, ' ',D.Colonia , 
		  ' ',D.Municipio, ' ', D.Estado,
		  ' ',D.CodigoPostal , 
		  ' (', CAST(TD.TipoDomicilio AS NVARCHAR(MAX)),')') AS IdDomicilioEntrega ,
		 --SPD.IdDomicilioEntrega,
		 MM.DescripcionLarga AS TextoLargo,
		ISNULL(SPD.IdUnidad,0) AS IdUnidad
		FROM MM_SolicitudPedidoDetalle AS SPD
		INNER JOIN dbo.MM_Material AS MM ON MM.IdMaterial = SPD.IdMaterial		
		LEFT JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = SPD.IdUnidad
		LEFT JOIN DG_Domicilio AS D ON D.IdDomicilio=SPD.IdDomicilioEntrega
		LEFT JOIN dbo.DG_TipoDomicilio TD ON TD.IdTipoDomicilio = D.IdTipoDomicilio
		WHERE IdSolicitudPedido = @IdSolicitudPedido

END

