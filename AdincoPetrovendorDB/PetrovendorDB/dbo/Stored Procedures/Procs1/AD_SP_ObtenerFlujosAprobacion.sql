USE [Petrovendor]
GO
DROP PROC IF EXISTS AD_SP_ObtenerFlujosAprobacion
GO
/****** Object:  StoredProcedure [dbo].[USP_SEL_ENT_EntregablesConfiguracionPorContratoMarcoLegal]    Script Date: 29/10/2024 12:44:56 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-04-2021  
-- Description: consultar todos los flujos por tipo de aprobación  de entrada
-- Description: Se agrega consulta para flujos de comprobante extranjero mercadero 28/01/2026
-- =============================================  
  
CREATE  PROCEDURE [dbo].[AD_SP_ObtenerFlujosAprobacion] 
@IdProveedor INT, 
@TipoAprobacion NVARCHAR(MAX)
AS  
 BEGIN  
  SET NOCOUNT ON  
  

  IF @TipoAprobacion='COMPRA_DIRECTA'
  BEGIN 
	  SELECT    
	  FT.IdFlujoTarea,   
	  FT.Nombre,   
	  FT.Descripcion,   
	  TF.Nombre AS TipoFlujo,   
	  A.IdAprobador,  
	  A.NoSecuencia,  
	  U.Nombre AS Aprobador,   
	  U.IdUsuario  
	  FROM  TA_FlujoTarea FT  
	  INNER JOIN TA_TipoFlujoTarea AS TF  
	   ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo  
	  LEFT JOIN dbo.TA_Aprobador A ON A.IdFlujoTarea = FT.IdFlujoTarea  
	  LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = A.IdUsuario  
	  WHERE  
	  IdProveedor = @IdProveedor 
	  AND IdTipoOperacion = 14 --> TIPO COMPRA DIRECTA 
	  AND ISNULL(Eliminado,0)=0  
	  ORDER BY FT.Nombre ASC  --> NO MOVER ORDER ASC 

  END    

  IF @TipoAprobacion='COMPROBANTE_EXTRANJERO_DIRECTO'
  BEGIN 

	  SELECT    
	  FT.IdFlujoTarea,   
	  FT.Nombre,   
	  FT.Descripcion,   
	  TF.Nombre AS TipoFlujo,   
	  A.IdAprobador,  
	  A.NoSecuencia,  
	  U.Nombre AS Aprobador,   
	  U.IdUsuario  
	  FROM  TA_FlujoTarea FT  
	  INNER JOIN TA_TipoFlujoTarea AS TF  
	   ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo  
	  LEFT JOIN dbo.TA_Aprobador A ON A.IdFlujoTarea = FT.IdFlujoTarea  
	  LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = A.IdUsuario  
	  WHERE  
	  FT.IdProveedor = @IdProveedor 
	  AND FT.IdTipoOperacion = 19 --> TIPO COMPROBANTE_EXTRANJERO_DIRECTO 
	  AND ISNULL(FT.Activo,0)=1  
	  ORDER BY FT.Nombre ASC  --> NO MOVER ORDER ASC

  END 

  IF @TipoAprobacion='COMPROBANTE_EXTRANJERO_MERCADEO'
  BEGIN 

	  SELECT    
	  FT.IdFlujoTarea,   
	  FT.Nombre,   
	  FT.Descripcion,   
	  TF.Nombre AS TipoFlujo,   
	  A.IdAprobador,  
	  A.NoSecuencia,  
	  U.Nombre AS Aprobador,   
	  U.IdUsuario  
	  FROM  TA_FlujoTarea FT  
	  INNER JOIN TA_TipoFlujoTarea AS TF  
	   ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo  
	  LEFT JOIN dbo.TA_Aprobador A ON A.IdFlujoTarea = FT.IdFlujoTarea  
	  LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = A.IdUsuario  
	  WHERE  
	  FT.IdProveedor = @IdProveedor 
	  AND FT.IdTipoOperacion = 16 -->  CTE --> Ta_TipoOperacion -->  Aprobación Pedimento/Comprobante Extranjero
	  AND ISNULL(FT.Activo,0)=1  
	  ORDER BY FT.Nombre ASC  --> NO MOVER ORDER ASC

  END 
 END