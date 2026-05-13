-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/01/2018
-- Description:	se agrega la justificacion
-- =============================================
CREATE PROCEDURE SP_MM_AgregarJustificacion
    @IdPedido INT,
    @Justificacion NVARCHAR(MAX),
    @Documento IMAGE,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    INSERT INTO dbo.AD_Documento
    (
        IdPedido,
        Documento,
        Justificacion
    )
    VALUES
    (   @IdPedido,     -- IdPedido - int
        @Documento,    -- Documento - image
        @Justificacion -- Justificacion - nvarchar(max)
    )
END
