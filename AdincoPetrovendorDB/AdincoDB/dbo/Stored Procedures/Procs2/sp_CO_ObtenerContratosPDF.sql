CREATE PROCEDURE [dbo].[sp_CO_ObtenerContratosPDF]
AS
BEGIN
	SELECT
		C.IdContrato,
		C.NumeroContrato,
		C.DescripcionContrato,
		C.IdContratista,
		C.IdAreaContractual,
		C.IDRegFiducidiario,
		C.Duracion,
		C.FechaFirma,
		C.InicioVigencia,
		C.FinVigencia,
		C.IdTipoContrato,
		C.ValorRegaliaAdicional,
		C.IncrementoProgramaMinimo,
		C.CreadoPor,
		C.CreadoEl,
		C.ModificadoPor,
		C.ModificadoEl,
		ISNULL(C.Activo, 0) Activo,
		C.PorcentajeRecuperacion,
		ISNULL(C.GasNoAsociado, 0) GasNoAsociado,
		ISNULL(C.IsPC, 0) IsPC,
		C.IdUbicacionGeografica,
		C.MesPresentacionCGI,
		C.IdRonda,
		ISNULL(C.IsConsorcio, 0) IsConsorcio,
		C.ParticipacionEstado,
		C.FechaArranqueEntregables,
		ISNULL(C.ContratoFicticio, 0) ContratoFicticio,
		CASE	
		WHEN	ISNULL(PDF.IdContratoPDF,0) >0
		THEN 1
		ELSE 0
		END AS PDF,
		ISNULL(C.UsaProcura, 0) UsaProcura
		FROM 
			CO_Contrato C (NOLOCK)
		LEFT JOIN
			CO_ContratoPDF PDF (NOLOCK)
		ON	C.IdContrato	=	PDF.IdContrato
END


