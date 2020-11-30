-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description: Saves a new monthly production record of a CIEP contract
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_InsertaProduccionMensualCIEP] 
-- Add the parameters for the stored procedure here
@IdContrato INT,
@QCE        FLOAT,
@API        FLOAT,
@Mes        DATE,
@IdUsuario  INT,
@IdIdioma   INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @InsertedRecord INT;
         -- Insert statements for procedure here
         -- Inserting the Production Log
         INSERT INTO [dbo].[CO_ProduccionCrudoMensualCIEP]
         ([IdContrato],
          [QCE],
          [API],
          [Mes],
          [CreadoPor],
          [CreadoEl],
          [ModificadoPor],
          [ModificadoEl],
          [Activo]
         )
         VALUES
         (@IdContrato,
          @QCE,
          @API,
          @Mes,
          @IdUsuario,
          CURRENT_TIMESTAMP,
          NULL,
          NULL,
          1
         );
         SELECT @InsertedRecord = @@IDENTITY;
         INSERT INTO [dbo].[CO_ProduccionCrudoMensualCIEP_Log]
         ([IdProduccionCrudoMensual],
          [IdContrato],
          [QCE],
          [API],
          [Mes],
          [CreadoPor],
          [CreadoEl],
          [ModificadoPor],
          [ModificadoEl],
          [Activo]
         )
         VALUES
         (@InsertedRecord,
          @IdContrato,
          @QCE,
          @API,
          @Mes,
          @IdUsuario,
          CURRENT_TIMESTAMP,
          NULL,
          NULL,
          1
         );
         SELECT @InsertedRecord AS INSERTADO,
                CONCAT('El volumen de producción se ha guardado exitosamente con el número de transacción (TR) ', @InsertedRecord) AS MSG;
     END;