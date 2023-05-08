-- =============================================
-- Author:		 Marcos Garcia
-- Create date:  06-12-2019
-- Description:	 Inserta la Relacion de las Factura 
--				 con los Contratos
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AsociarFacturaContratos] 
-- [SP_FI_ConsultaComprobantesPorProveedor] 10002,3,10002
@IdFactura          INT, 
@IdContratoRelacion INT, 
@IdContrato         INT, 
@IdUsuario          INT, 
@Accion             INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;		
         --================= Inserción a Tabla ==================
         IF(@Accion = 0)
             BEGIN
                 INSERT INTO dbo.FI_FacturaContrato
                 ([IdFactura], 
                  [IdContrato], 
                  [CreadoEn], 
                  [CreadoPor], 
                  [ModificadoEn], 
                  [ModificadoPor]
                 )
                 VALUES
                 (@IdFactura, 
                  @IdContratoRelacion, 
                  GETDATE(), -- 
                  @IdUsuario, 
                  NULL, 
                  NULL
                 );
             END;
         IF(@Accion <> 0)
             BEGIN
                 INSERT INTO dbo.FI_FacturaContrato
                 ([IdFactura], 
                  [IdContrato], 
                  [CreadoEn], 
                  [CreadoPor], 
                  [ModificadoEn], 
                  [ModificadoPor]
                 )
                 VALUES
                 (@IdFactura, 
                  @IdContratoRelacion, 
                  NULL, -- 
                  NULL, 
                  GETDATE(), 
                  @IdUsuario
                 );
             END;
         --================= Mensaje de Error ==================
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;