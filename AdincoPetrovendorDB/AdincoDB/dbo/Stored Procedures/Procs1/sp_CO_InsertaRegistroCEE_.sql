-- Stored Procedure

-- =============================================
-- Author:		Miguel Gomez
-- Create date: Diciembre 2014
-- Description:	Inserta un nuevo registro
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_InsertaRegistroCEE_] 
-- Add the parameters for the stored procedure here
@IdPrograma             INT,
@IdFactura              INT,
@MontoRegistro          DECIMAL(18, 4),
@InicioEjecucion        DATE,
@FinEjecucion           DATE,
@Comentarios            NVARCHAR(MAX),
@MesPresentacion        DATE,
@IdEstado               INT,
@IdUsuarioCreadoPor     INT,
@IdUsuarioModPor        INT,
@FecMovto               DATETIME,
@IdInstalacion          INT,
@IdCuentaCSH            INT,
@Poliza                 INT,
@IdPedimentoComprobante INT,
@CvTipoDoc              INT,
@CostoAtrib             BIT--,
--@IdContrato             INT
AS
         BEGIN
             SET @IdFactura = CASE
                                  WHEN @IdFactura = 0
                                  THEN NULL
                                  ELSE @IdFactura
                              END;
             SET @IdPedimentoComprobante = CASE
                                               WHEN @IdPedimentoComprobante = 0
                                               THEN NULL
                                               ELSE @IdPedimentoComprobante
                                           END;
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @insertado INT;
		   
/*Seleccionar el mes de presentación del gasto*/

             --SELECT @MesPresentacion = MesPresentacionCGI
             --FROM dbo.CO_Contrato
             --WHERE IdContrato = @IdContrato;
		   
/**/

-- Insert statements for procedure here

             INSERT INTO CO_Registro
([IdPrograma],
 [IdFactura],
 [MontoRegistro],
 [InicioEjecucion],
 [FinEjecucion],
 [Comentarios],
 [MesPresentacion],
 [IdEstado],
 [IdUsuarioCreadoPor],
 --[IdUsuarioModPor],
 [FecMovto],
 [IdInstalacion],
 [IdCatalogoCuentasSH],
 [Poliza],
 [IdPedimentoComprobante],
 [CvTipoDocFacturacion],
 [CostosAtribuiblesAdministracion]
)
             VALUES
(@IdPrograma,
 @IdFactura,
 @MontoRegistro,
 @InicioEjecucion,
 @FinEjecucion,
 @Comentarios,
 '20180301' ,  -- @MesPresentacion,
 10004,
 @IdUsuarioCreadoPor,
 --@IdUsuarioModPor,
 CURRENT_TIMESTAMP,
 @IdInstalacion,
 @IdCuentaCSH,
 @Poliza,
 @IdPedimentoComprobante,
 @CvTipoDoc,
 @CostoAtrib
);
             SELECT @insertado = @@IDENTITY;
             SELECT @insertado AS INSERTADO,
                    CONCAT('El registro se ha guardado exitosamente con el id ', @insertado) AS MSG;
         END;
	    	    --SELECT * FROM dbo.CO_Registro WHERE IdRegistro = 9490
