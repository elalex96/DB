--Adinco es 1 petrovendor es 0
CREATE PROCEDURE [dbo].[SP_FI_ExisteUUIDPetrovendorProcura] (@UUID NVARCHAR(MAX))
AS
BEGIN
    DECLARE @tablaAuxiliar TABLE
    (
        IdFactura INT,
        ProcuraPetrovendor BIT,
        Estatus INT,
        IdOperacion INT,
		IsEliminado BIT--
    )
    DECLARE @EncontradoPetrovendor INT

    -- se insertan las de petrovendor
    -- se revisa su estatus
    INSERT INTO @tablaAuxiliar
    (
        IdFactura,
        ProcuraPetrovendor,
        Estatus,
        IdOperacion,
		IsEliminado--
    )
    SELECT fact.IdFactura,
           0, --significa que es petrovendor
           T.IdEstatus,
           opera.IdOperacion,
		   fact.IsEliminado--
    FROM Petrovendor.dbo.FI_Factura fact
        INNER JOIN Petrovendor.dbo.TA_Operacion opera
            ON fact.IdFactura = opera.IdDocumento
        INNER JOIN Petrovendor.dbo.TA_Tarea T
            ON T.IdOperacion = opera.IdOperacion
    WHERE UUID = @UUID --AND fact.IsEliminado IS NULL OR fact.IsEliminado = 0


    --se insertan las de Adinco
    INSERT INTO @tablaAuxiliar
    (
        IdFactura,
        ProcuraPetrovendor,
        Estatus,
        IdOperacion,
		IsEliminado--
    )
    SELECT IdFactura,
           1, --significa que es Adinco
           2, --Procura la cargo en automatico con un 2 ya que estas ya fueron aprobadas
           0, --se inserta es 0 yaque es adinco el en automatico debe de tomarla como aprobada
		   0 --Ninguna de adinco esta eliminada--
    FROM Adinco.dbo.FI_Factura
    WHERE UUID = @UUID


    --Retorno a la vista
    SELECT *
    FROM @tablaAuxiliar
    ORDER BY IdOperacion -- lo ordeno por idoperacion para que se tome la mas reciente

END


