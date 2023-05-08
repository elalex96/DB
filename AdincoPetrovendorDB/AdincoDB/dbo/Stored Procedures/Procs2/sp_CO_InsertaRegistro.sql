-- =============================================
-- Author:		Miguel Gomez
-- Create date: Diciembre 2014
-- Description:	Inserta un nuevo registro
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_InsertaRegistro] 
-- Add the parameters for the stored procedure here
@IdPrograma         INT,
@IdFactura          INT,
@MontoRegistro      DECIMAL(18, 4),
@InicioEjecucion    DATE,
@FinEjecucion       DATE,
@Comentarios        NVARCHAR(MAX),
@MesPresentacion    DATE,
@IdEstado           INT,
@IdUsuarioCreadoPor INT,
@IdUsuarioModPor    INT,
@FecMovto           DATETIME,
@IdInstalacion      INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @insertado INT;
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
          [IdUsuarioModPor],
          [FecMovto],
          [IdInstalacion]
         )
         VALUES
         (@IdPrograma,
          @IdFactura,
          @MontoRegistro,
          @InicioEjecucion,
          @FinEjecucion,
          @Comentarios,
          '20180401',--DATEFROMPARTS(year( CURRENT_TIMESTAMP) , month( CURRENT_TIMESTAMP),1),
          10004,
          @IdUsuarioCreadoPor,
          @IdUsuarioModPor,
          CURRENT_TIMESTAMP,
          @IdInstalacion
         );
         SELECT @insertado = @@IDENTITY;
    
         SELECT @insertado AS INSERTADO,
                CONCAT('El registro se ha guardado exitosamente con el id ', @insertado) AS MSG;
     END;

