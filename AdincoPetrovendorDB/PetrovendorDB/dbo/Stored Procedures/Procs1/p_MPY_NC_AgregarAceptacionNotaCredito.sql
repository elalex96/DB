
-- =============================================  
-- Author:  LUIS DAVID  
-- Create date: 08-11-19  
-- Description: Agregar relación de Nota de credito- AceptacionPedido   
-- =============================================  
CREATE PROCEDURE [dbo].[p_MPY_NC_AgregarAceptacionNotaCredito]   
 -- Add the parameters for the stored procedure here  
@IdProveedor        INT,  
@IdAceptacionPedido INT,  
@IdFactura INT,   
@IdUsuario INT,  
@TipoRelacion NVARCHAR(MAX),  
@NoParcialidad INT,  
@CFDIRelacionados NVARCHAR(MAX)  
  
AS  
     BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
         SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
  INSERT INTO dbo.MPY_MM_AceptacionNotaCredito  
  (  
      IdFacturaNotaCredito,  
      IdAceptacionPedido,  
      TipoRelacion,  
      CFDIRelacionados,  
      NoParcialidad,  
      CreadoEl,  
      CreadoPor,  
      Activo  ,
	  IdEstatus
  )  
  VALUES  
  (   @IdFactura,         -- IdFacturaNotaCredito - int  
      @IdAceptacionPedido,         -- IdAceptacionPedido - int  
      @TipoRelacion,       -- TipoRelacion - nvarchar(50)  
      @CFDIRelacionados,       -- CFDIRelacionados - nvarchar(max)  
      @NoParcialidad,         -- NoParcialidad - int  
      GETDATE(), -- CreadoEl - datetime  
      @IdUsuario,         -- CreadoPor - int  
      1 ,    -- Activo - bit ,
	  1
      )  
    
   
  
 SELECT SCOPE_IDENTITY() AS IdAceptacionNotaCredito  
  
    END  
  