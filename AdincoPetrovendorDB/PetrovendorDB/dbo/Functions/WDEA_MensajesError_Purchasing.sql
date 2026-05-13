CREATE FUNCTION WDEA_MensajesError_Purchasing
(@Purchasing varchar(300),
@IdBitacora int)
RETURNS varchar(max) AS
BEGIN
    DECLARE @MENSAJE varchar(max);
	SELECT @MENSAJE = COALESCE(@MENSAJE + ' ', '') + REPLACE(Mensaje,',','')
	FROM WDEA_Bitacora_AdincoSAP
	where Purchasing_Document = @Purchasing
	and IdBitacoraLectura = @IdBitacora

	RETURN @MENSAJE;
END;