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
		C.Activo,
		C.PorcentajeRecuperacion,
		C.GasNoAsociado,
		C.IsPC,
		C.IdUbicacionGeografica,
		C.MesPresentacionCGI,
		C.IdRonda,
		C.IsConsorcio,
		C.ParticipacionEstado,
		C.FechaArranqueEntregables,
		C.ContratoFicticio,
		CASE	
		WHEN	ISNULL(PDF.IdContratoPDF,0) >0
		THEN 1
		ELSE 0
		END AS PDF,
		C.UsaProcura
		FROM 
			CO_Contrato C
		LEFT JOIN
			CO_ContratoPDF PDF
		ON	C.IdContrato	=	PDF.IdContrato
END


