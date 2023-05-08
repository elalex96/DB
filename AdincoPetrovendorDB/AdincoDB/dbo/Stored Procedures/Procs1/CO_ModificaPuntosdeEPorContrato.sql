-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180825
-- Description:Modifica los puntos de entrega por contrato
-- =============================================
CREATE PROCEDURE [CO_ModificaPuntosdeEPorContrato]
    @Nombre NVARCHAR(MAX),
    @TagPatinMedicion NVARCHAR(100),
    @TipoMedidor NVARCHAR(100),
    @TagMedidor NVARCHAR(100),
    @Clasificacion NVARCHAR(100),
    @PuntoEntregaID INT,
    @idusuario INT,
    @idContrato INT,
    @activo BIT
	
AS
BEGIN

    SET NOCOUNT ON;
    -- =============================================
    DECLARE @cont INT;
    SELECT @cont = COUNT(PuntoEntregaID)
    FROM CO_PuntosdeEntrega
    WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND PuntoEntregaID <> @PuntoEntregaID;

    IF (@cont >= 1)
    BEGIN
        PRINT ('Ya hay un punto de entrega con el mismo nombre');
    END;
    ELSE
    BEGIN
        UPDATE CO_PuntosdeEntrega
        SET Nombre = LTRIM(RTRIM(@Nombre)),
            TagPatinMedicion = LTRIM(RTRIM(@TagPatinMedicion)),
            TipoMedidor = LTRIM(RTRIM(@TipoMedidor)),
            TagMedidor = LTRIM(RTRIM(@TagMedidor)),
            Clasificacion = LTRIM(RTRIM(@Clasificacion)),
            ModificadoPor = @idusuario,
            ModificadoEl = GETDATE(),
            Activo = @activo
        WHERE PuntoEntregaID = @PuntoEntregaID;

    END;
END;