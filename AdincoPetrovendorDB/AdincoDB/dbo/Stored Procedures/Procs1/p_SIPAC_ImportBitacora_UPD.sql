
-- p_SIPAC_ImportBitacora_UPD 43,36314,null
create PROC p_SIPAC_ImportBitacora_UPD
@Id int,
@IdError int,
@MesReporte Date=null
as
BEGIN

	UPDATE SIPAC_ImportBitacora
	set IdError = case when IdError is null then 
						case when isnull(@IdError,0) = 0 THEN IdError Else  @IdError END
					   else IdError
				END,
		MesReporte = case when @MesReporte is not null then @MesReporte Else MesReporte End
	WHERE Id = @Id

END

