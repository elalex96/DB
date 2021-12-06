USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_AgregarDocMatrizOperacion]    Script Date: 26/11/2021 02:01:51 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
ALTER PROCEDURE [dbo].[MM_SP_AgregarDocMatrizOperacion]
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
