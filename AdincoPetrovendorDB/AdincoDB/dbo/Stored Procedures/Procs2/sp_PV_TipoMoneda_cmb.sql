CREATE PROC sp_PV_TipoMoneda_cmb
AS
    BEGIN
        SELECT tm.IdMoneda, 
               tm.TipoMoneda, 
               tm.TipoMonedaCorto
        FROM PV_TipoMoneda tm;
        --where	ISNULL(tm.Eliminado,0)		<>		1
    END;