-- =============================================  
-- Author:  Daniel Cruz  
-- Create date: 14-10-2020  
-- Description: Agregar relación de Nota de credito- AceptacionPedido   
-- =============================================  
CREATE PROCEDURE [dbo].[SP_PR_MM_AgregarAceptacionNotaCredito]
    -- Add the parameters for the stored procedure here  
    @IdProveedor INT,
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
	/*SP PARA AGREGAR RELACIÓN DE LA NOTA DE CREDITO CON UNA ACEPTACIÓN PEDIDO*/
    -- Insert statements for procedure here  
    INSERT INTO dbo.MM_AceptacionNotaCredito
    (
        IdFacturaNotaCredito,
        IdAceptacionPedido,
        TipoRelacion,
        CFDIRelacionados,
        NoParcialidad,
        CreadoEl,
        CreadoPor,
        Activo
    )
    VALUES
    (   @IdFactura,          -- IdFacturaNotaCredito - int  
        @IdAceptacionPedido, -- IdAceptacionPedido - int  
        @TipoRelacion,       -- TipoRelacion - nvarchar(50)  
        @CFDIRelacionados,   -- CFDIRelacionados - nvarchar(max)  
        @NoParcialidad,      -- NoParcialidad - int  
        GETDATE(),           -- CreadoEl - datetime  
        @IdUsuario,          -- CreadoPor - int  
        1                    -- Activo - bit     
        );
		
    SELECT SCOPE_IDENTITY() AS IdAceptacionNotaCredito;

END;

