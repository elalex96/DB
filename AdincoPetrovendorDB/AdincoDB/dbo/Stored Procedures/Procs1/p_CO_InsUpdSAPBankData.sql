CREATE proc [dbo].[p_CO_InsUpdSAPBankData]
@pIdContrato	int,
@pBankAccountNumber	varchar(10),
@pBankName	varchar(50),
@pAccountOwnerName	varchar(150),
@pCurrency	varchar(3)
as


	if not exists(
		select 1
		from [CO_SAPBankData]
		where IdContrato = @pIdContrato and
		BankAccountNumber = @pBankAccountNumber 
	)
	begin

		insert into [dbo].[CO_SAPBankData](
			IdContrato,BankAccountNumber,BankName,AccountOwnerName,Currency
		)
		values(

			@pIdContrato,@pBankAccountNumber,@pBankName,@pAccountOwnerName,@pCurrency

		)
	end	
	else
	begin

		update [CO_SAPBankData]
		set BankName=@pBankName,
			AccountOwnerName = @pAccountOwnerName,
			Currency = @pCurrency
		where IdContrato = @pIdContrato and
		BankAccountNumber = @pBankAccountNumber 

	end