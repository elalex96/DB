-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Insert a new record for an accepted spend amount
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_InsertaGEAceptadosMes] 
-- Add the parameters for the stored procedure here
@IdContrato  INT,
@GEAprobados MONEY,
@Mes         DATE,
@IdUsuario   INT,
@IdIdioma    INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @InsertedRecord INT;
         -- Insert statements for procedure here


         INSERT INTO [dbo].[CO_GEAceptadosMes]
         ([IdContrato],
          [GEAprobados],
          [Mes],
          [CreadoPor],
          [CreadoEl],
          [ModificadoPor],
          [ModificadoEl],
          [Activo]
         )
         VALUES
         (@IdContrato,
          @GEAprobados,
          @Mes,
          @IdUsuario,
          CURRENT_TIMESTAMP,
          @IdUsuario,
          CURRENT_TIMESTAMP,
          1
         );
         SELECT @InsertedRecord = @@IDENTITY;
         INSERT INTO [dbo].[CO_GEAceptadosMes_Log]
         ([IdGEAceptadoMes],
          [IdContrato],
          [GEAprobados],
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
          @GEAprobados,
          @Mes,
          @IdUsuario,
          CURRENT_TIMESTAMP,
          @IdUsuario,
          CURRENT_TIMESTAMP,
          1
         );
         SELECT @InsertedRecord AS INSERTADO,
                CONCAT('El monto de gasto se ha guardado exitosamente con el número de operación (NO) ', @InsertedRecord) AS MSG;
     END;