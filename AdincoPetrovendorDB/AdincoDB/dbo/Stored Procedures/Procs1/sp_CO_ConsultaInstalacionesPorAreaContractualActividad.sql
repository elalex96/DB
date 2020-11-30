-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2 Diciembre 2014
-- Description:	Obtiene todas las instalaciones para registro
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaInstalacionesPorAreaContractualActividad]
-- Add the parameters for the stored procedure here
@IdContrato  INT = 0,
@IdActividad INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @IdAreaContractual AS INT;
         SELECT @IdAreaContractual = IdAreaContractual
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;
         IF(@IdActividad = 0)
             -- Insert statements for procedure here
             SELECT IdInstalacion,
                    NombreInstalacion,
                    IdInstalacionPemex,
                    EsBolsa,
                    IdActividad,
                    IdUsuario,
                    FecMovto,
                    NombreInstalacionAlterno,
                    IdCatalogoSCIEP,
                    IdAreaContractual,
                    Activo
             FROM CO_Instalacion
             WHERE(IdAreaContractual = @IdAreaContractual)
                  AND (EsBolsa = 0)
                  AND (Activo = 1)
             ORDER BY NombreInstalacion;
         ELSE
         SELECT IdInstalacion,
                NombreInstalacion,
                IdInstalacionPemex,
                EsBolsa,
                IdActividad,
                IdUsuario,
                FecMovto,
                NombreInstalacionAlterno,
                IdCatalogoSCIEP,
                IdAreaContractual,
                Activo
         FROM CO_Instalacion
         WHERE(IdAreaContractual = @IdAreaContractual)
              AND (EsBolsa = 0)
              AND (IdActividad = @IdActividad)
              AND (Activo = 1)
         ORDER BY NombreInstalacion;
     END;