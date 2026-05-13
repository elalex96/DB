-- =============================================
-- Author:      <Jose Roman>
-- Create date: <2017>
-- Description: <Se guarda el Id de encuesta con sus porcentajes de calculo>
-- =============================================
-- Author:      <Jose Roman>
-- Update date: <23-11-2018>
-- Description: <Se habilita la opcion para modificar la solped>
-- =============================================
-- Author:      <Alexander Gomez>
-- Update date: <26/11/2021>
-- Description: <se optmimiza para mejora de carga>
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_AgregarDocMatrizOperacion]
    @IdProveedor INT,
    @NombreDoc VARCHAR(MAX),
    @IdOperacion INT,
    @PorcentajeET FLOAT,
    @PorcentajeEC FLOAT
AS
BEGIN
SET NOCOUNT ON
     UPDATE dbo.TA_DocMatrizOperacion
        SET IdProveedor = @IdProveedor,
            NombreDoc = @NombreDoc,
            PorcentajeET = @PorcentajeET,
            PorcentajeEC = @PorcentajeEC
        WHERE IdOperacion = @IdOperacion
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO dbo.TA_DocMatrizOperacion
            (
                IdProveedor,
                NombreDoc,
                IdOperacion,
                PorcentajeET,
                PorcentajeEC
            )
            VALUES
            (   @IdProveedor,   -- IdProveedor - int
                @NombreDoc,  -- NombreDoc - varchar(max)
                @IdOperacion,   -- IdOperacion - int
                @PorcentajeET, -- PorcentajeET - float
                @PorcentajeEC  -- PorcentajeEC - float
            )
    END
END