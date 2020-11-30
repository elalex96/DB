-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180818
-- Description:	Extrae Precios de los hidrocarburos
-- =============================================
CREATE PROCEDURE COM_ExtraePreciosHidrocarburo --'20180801',3,1
    @Mes DATE,
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT Hidrocarburo,
           CostoUnitarioComercializacion,
           Mes,
           COM_CostoUnitarioHidrocarburo.IdTipoHidrocarburo AS idTipoHidrocarburo,
           IdContrato
    FROM dbo.COM_CostoUnitarioHidrocarburo
        JOIN dbo.CO_TipoHidrocarburo
            ON CO_TipoHidrocarburo.IdTipoHidrocarburo = COM_CostoUnitarioHidrocarburo.IdTipoHidrocarburo
    WHERE IdContrato = @idContrato
          AND Mes = @Mes
    ORDER BY Mes DESC;
END;
