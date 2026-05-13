IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_HistorialBitacoraPresupuesto'
    )
    DROP PROCEDURE USP_SEL_CO_HistorialBitacoraPresupuesto;
GO
CREATE PROCEDURE dbo.USP_SEL_CO_HistorialBitacoraPresupuesto
    @IdContrato             INT,
    @IdUsuario              INT,
    @IdContratoSeleccionado INT
AS
    BEGIN
        SET NOCOUNT ON;

        IF @IdContratoSeleccionado IS NULL
           OR @IdContratoSeleccionado <= 0
            BEGIN
                RAISERROR('IdContrato inválido.', 16, 1);
                RETURN;
            END

        SELECT
            b.IdBitacora,
            b.IdRegistro,
            b.Justificacion,
            b.CreadoEn,
            b.CreadoPor,
            ISNULL(u.Nombre, 'Usuario desconocido') AS NombreUsuario,
            CASE
                WHEN b.IdLineaPresupuestoAnterior IS NULL
                    THEN NULL
                ELSE
                    CAST(b.IdLineaPresupuestoAnterior AS NVARCHAR(50))
            END                                     AS LineaPresupuestoAnterior,
            CASE
                WHEN b.IdLineaPresupuestoNuevo IS NULL
                    THEN NULL
                ELSE
                    CAST(b.IdLineaPresupuestoNuevo AS NVARCHAR(50))
            END                                     AS LineaPresupuestoNuevo,
            b.IdLineaPresupuestoAnterior,
            b.IdLineaPresupuestoNuevo,
            pAnterior.Nombre                        AS PresupuestoAnterior,
            pNuevo.Nombre                           AS PresupuestoNuevo
        FROM
            dbo.CO_Registro_Bitacora       b WITH (NOLOCK)
            INNER JOIN
                dbo.CO_Registro            r WITH (NOLOCK)
                    ON b.IdRegistro = r.IdRegistro
            INNER JOIN
                dbo.FI_Factura             f WITH (NOLOCK)
                    ON r.IdFactura = f.IdFactura
                       AND f.IdContrato = @IdContratoSeleccionado
            LEFT JOIN
                dbo.AP_Usuario             u WITH (NOLOCK)
                    ON b.CreadoPor = u.UsuarioID
            LEFT JOIN
                dbo.CO_LineaPresupuestoMes lpAnterior WITH (NOLOCK)
                    ON b.IdLineaPresupuestoAnterior = lpAnterior.IdLineaPresupuestoMes
            LEFT JOIN
                dbo.CO_LineaPresupuestoMes lpNuevo WITH (NOLOCK)
                    ON b.IdLineaPresupuestoNuevo = lpNuevo.IdLineaPresupuestoMes
            LEFT JOIN
                dbo.CO_Presupuesto         pAnterior WITH (NOLOCK)
                    ON lpAnterior.IdPresupuesto = pAnterior.IdPresupuesto
            LEFT JOIN
                dbo.CO_Presupuesto         pNuevo WITH (NOLOCK)
                    ON lpNuevo.IdPresupuesto = pNuevo.IdPresupuesto
        WHERE
            f.IdContrato = @IdContratoSeleccionado
        ORDER BY
            b.CreadoEn DESC;
    END