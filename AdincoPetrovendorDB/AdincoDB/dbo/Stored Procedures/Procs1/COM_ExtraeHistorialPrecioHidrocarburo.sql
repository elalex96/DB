-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180818
-- Description:	Extrae el historial de los precios de un hidrocarburo
-- =============================================
CREATE PROCEDURE COM_ExtraeHistorialPrecioHidrocarburo
    @idHidrocarburo INT,
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT Hidrocarburo,CostoUnitarioComercializacion,
           Mes,
		   COM_CostoUnitarioHidrocarburo.IdTipoHidrocarburo AS idTipoHidrocarburo
		   ,IdContrato
    FROM dbo.COM_CostoUnitarioHidrocarburo
        JOIN dbo.CO_TipoHidrocarburo
            ON CO_TipoHidrocarburo.IdTipoHidrocarburo = COM_CostoUnitarioHidrocarburo.IdTipoHidrocarburo
    WHERE IdContrato = @idContrato
          AND COM_CostoUnitarioHidrocarburo.IdTipoHidrocarburo = @idHidrocarburo
		  ORDER BY mes DESC;
END;