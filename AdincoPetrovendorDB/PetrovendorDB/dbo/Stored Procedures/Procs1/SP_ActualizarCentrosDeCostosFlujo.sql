-- =============================================  
-- Author: Daniel AC  
-- Create date: 28/11/2019  
-- Description: Se agrego configuración de not para usuarios de pr y relación pedido y pr DEA  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_ActualizarCentrosDeCostosFlujo] @IdCentroCosto       INT, 
                                                          @CentroCosto         NVARCHAR(MAX), 
                                                          @numero              VARCHAR(MAX), 
                                                          @IdFlujo             INT           = 0, 
                                                          @IdFlujoFactura      INT           = 0, 
                                                          @IdFlujoComprobante  INT           = 0, 
                                                          @UsuariosNotPR       NVARCHAR(MAX), 
                                                          @UsuariosNotPOPedido NVARCHAR(MAX), 
                                                          @IdProveedor         INT, 
                                                          @IdUsuario           INT
AS
    BEGIN  
        -- SET NOCOUNT ON added to prevent extra result sets from  
        -- interfering with SELECT statements.  
        SET NOCOUNT ON;
        IF @IdFlujo = 0
            SET @IdFlujo = NULL;
        IF @IdFlujoFactura = 0
            SET @IdFlujoFactura = NULL;
        IF @IdFlujoComprobante = 0
            SET @IdFlujoComprobante = NULL;
        UPDATE [dbo].[CC_CentroCosto]
          SET 
              [CentroCosto] = @CentroCosto, 
              [numero] = @numero
        WHERE [IdCentroCosto] = @IdCentroCosto;
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.RelacionCentroCostoFlujoAprob
            WHERE IdCentroCosto = @IdCentroCosto
        )
            INSERT INTO dbo.RelacionCentroCostoFlujoAprob
            (IdCentroCosto, 
             IdFlujo, 
             IdFlujoFactura, 
             IdFlujoComprobante, 
             Activo
            )
            VALUES
            (@IdCentroCosto, -- IdCentroCosto - int  
             @IdFlujo, -- IdFlujo - int  
             @IdFlujoFactura, 
             @IdFlujoComprobante, 
             1               -- Activo - bit  
            );
            ELSE
            UPDATE dbo.RelacionCentroCostoFlujoAprob
              SET 
                  IdFlujo = @IdFlujo, 
                  IdFlujoFactura = @IdFlujoFactura, 
                  IdFlujoComprobante = @IdFlujoComprobante
            WHERE IdCentroCosto = @IdCentroCosto;

        ---ACTUALIZAR NOTIFICACIONES PARA USUARIOS DE NOT DE SOLICITUD DE CARGA DE PR   

        EXEC dbo.DEA_SP_AgregarActualizarNotificaciones 
             @IdProveedor = @IdProveedor, -- int  
             @IdUsuario = @IdUsuario, -- int  
             @TipoNotificacion = N'NOT_CARGA_PR', -- nvarchar(max)  
             @Usuarios = @UsuariosNotPR, -- nvarchar(max)  
             @IdCentroCosto = @IdCentroCosto;       -- int  
        -------ACTUALIZAR NOTIFICACIONES PARA USUARIOS DE NOT DE SOLICITUD DE RELACIÓND DE PO PEDIDO    
        EXEC dbo.DEA_SP_AgregarActualizarNotificaciones 
             @IdProveedor = @IdProveedor, -- int  
             @IdUsuario = @IdUsuario, -- int  
             @TipoNotificacion = N'SOLITAR_RELACION_PRPO', -- nvarchar(max)  
             @Usuarios = @UsuariosNotPOPedido, -- nvarchar(max)  
             @IdCentroCosto = @IdCentroCosto;
    END;